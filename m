From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v6 8/10] xen-netback: Add stat counters for frag_list
 skbs
Date: Thu, 6 Mar 2014 12:41:49 +0000
Message-ID: <53186D0D.3010402@citrix.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com> <1393972341-21135-9-git-send-email-zoltan.kiss@citrix.com> <20140305123546.GI19620@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:59450 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbaCFMlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 07:41:53 -0500
In-Reply-To: <20140305123546.GI19620@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/14 12:35, Wei Liu wrote:
> On Tue, Mar 04, 2014 at 10:32:19PM +0000, Zoltan Kiss wrote:
>> These counters help determine how often the guest sends a packet with more
>> than MAX_SKB_FRAGS frags.
>>
>> NOTE: if bisect brought you here, you should apply the series up until #9,
>> otherwise malicious guests can block other guests by not releasing their sent
>> packets.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> ---
>>   drivers/net/xen-netback/common.h    |    1 +
>>   drivers/net/xen-netback/interface.c |    7 +++++++
>>   drivers/net/xen-netback/netback.c   |    1 +
>>   3 files changed, 9 insertions(+)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index eac171e..d8a2298 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -170,6 +170,7 @@ struct xenvif {
>>   	unsigned long tx_zerocopy_sent;
>>   	unsigned long tx_zerocopy_success;
>>   	unsigned long tx_zerocopy_fail;
>> +	unsigned long tx_frag_overflow;
>>
>>   	/* Miscellaneous private stuff. */
>>   	struct net_device *dev;
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index adfed30..ba5be2f 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -252,6 +252,13 @@ static const struct xenvif_stat {
>>   		"tx_zerocopy_fail",
>>   		offsetof(struct xenvif, tx_zerocopy_fail)
>>   	},
>> +	/* Number of packets exceeding MAX_SKB_FRAG slots. You should use
>> +	 * a guest with the same MAX_SKB_FRAG
>> +	 */
>> +	{
>> +		"tx_frag_overflow",
>> +		offsetof(struct xenvif, tx_frag_overflow)
>> +	},
>
> This patch break bisection with a cause different than "unable to handle
> too many frags", because previous patch makes use of this
> tx_frag_overflow. It's harmless to merge this one into previous one.
Ok

>
>>   };
>>
>>   static int xenvif_get_sset_count(struct net_device *dev, int
>>   string_set)
