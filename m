From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 08/26] net: add info struct for LAG changeupper
Date: Wed, 2 Dec 2015 12:07:51 +0100
Message-ID: <565ED107.3090806@cumulusnetworks.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-9-git-send-email-jiri@resnulli.us>
 <565ECF2F.7050500@cumulusnetworks.com>
 <20151202110647.GF2355@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37888 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757103AbbLBLHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 06:07:54 -0500
Received: by wmec201 with SMTP id c201so52784874wme.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 03:07:53 -0800 (PST)
In-Reply-To: <20151202110647.GF2355@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2015 12:06 PM, Jiri Pirko wrote:
> Wed, Dec 02, 2015 at 11:59:59AM CET, nikolay@cumulusnetworks.com wrote:
>> On 12/01/2015 02:48 PM, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This struct will be shared by bonding and team to pass internal
>>> information to notifier listeners.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  include/linux/netdevice.h | 13 +++++++++++++
>>>  1 file changed, 13 insertions(+)
>>>
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index a55be5b..7ea3e83 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -2108,6 +2108,19 @@ struct pcpu_sw_netstats {
>>>  #define netdev_alloc_pcpu_stats(type)					\
>>>  	__netdev_alloc_pcpu_stats(type, GFP_KERNEL);
>>>  
>>> +enum netdev_lag_tx_type {
>>> +	NETDEV_LAG_TX_TYPE_UNKNOWN,
>>> +	NETDEV_LAG_TX_TYPE_RANDOM,
>>> +	NETDEV_LAG_TX_TYPE_BROADCAST,
>>> +	NETDEV_LAG_TX_TYPE_ROUNDROBIN,
>>> +	NETDEV_LAG_TX_TYPE_ACTIVEBACKUP,
>>> +	NETDEV_LAG_TX_TYPE_HASH,
>>> +};
>>
>> There're 2 more modes supported by the bonding which aren't supported by team,
>> RLB and TLB. Since you've included _RANDOM, for completeness you can add
>> these, too.
> 
> For now it is "NETDEV_LAG_TX_TYPE_UNKNOWN". If needed to be identified
> by driver, it can be easily added.
> 

Out of curiosity, is _RANDOM needed to be identified by the driver ? :-)

> 
>>
>>> +
>>> +struct netdev_lag_upper_info {
>>> +	enum netdev_lag_tx_type tx_type;
>>> +};
>>> +
>>>  #include <linux/notifier.h>
>>>  
>>>  /* netdevice notifier chain. Please remember to update the rtnetlink
>>>
>>
