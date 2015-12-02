From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 10/26] bonding: fill-up LAG changeupper info
 struct and pass it along
Date: Wed, 2 Dec 2015 12:07:22 +0100
Message-ID: <20151202110722.GG2355@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-11-git-send-email-jiri@resnulli.us>
 <565ECF5F.3060002@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34615 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbbLBLHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 06:07:24 -0500
Received: by wmvv187 with SMTP id v187so249207755wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 03:07:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <565ECF5F.3060002@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 12:00:47PM CET, nikolay@cumulusnetworks.com wrote:
>On 12/01/2015 02:48 PM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Initialize netdev_lag_upper_info structure by TX type according to
>> current bonding mode and pass it along via netdev_master_upper_dev_link.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 43 +++++++++++++++++++++++++++--------------
>>  1 file changed, 29 insertions(+), 14 deletions(-)
>> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index fa3ed1d..8747746 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1198,26 +1198,41 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>>  	return ret;
>>  }
>>  
>> -static int bond_master_upper_dev_link(struct net_device *bond_dev,
>> -				      struct net_device *slave_dev,
>> -				      struct slave *slave)
>> +static enum netdev_lag_tx_type bond_lag_tx_type(struct bonding *bond)
>>  {
>> +	switch (BOND_MODE(bond)) {
>> +	case BOND_MODE_ROUNDROBIN:
>> +		return NETDEV_LAG_TX_TYPE_ROUNDROBIN;
>> +	case BOND_MODE_ACTIVEBACKUP:
>> +		return NETDEV_LAG_TX_TYPE_ACTIVEBACKUP;
>> +	case BOND_MODE_XOR:
>> +	case BOND_MODE_8023AD:
>> +		return NETDEV_LAG_TX_TYPE_HASH;
>> +	default:
>> +		return NETDEV_LAG_TX_TYPE_UNKNOWN;
>> +	}
>> +}
>
>Bonding also has the broadcast mode (NETDEV_LAG_TX_BROADCAST).

Right, I missed that. Will add. Thanks!


>
>> +
>[snip]
>
