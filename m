From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Tue, 17 May 2016 10:41:45 +0200
Message-ID: <20160517084145.GA2057@nanopsycho.orion>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
 <1463053730-14991-2-git-send-email-jiri@resnulli.us>
 <20160517083908.GA13823@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33025 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbcEQIls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 04:41:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id r12so2829654wme.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 01:41:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160517083908.GA13823@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 17, 2016 at 10:39:08AM CEST, tgraf@suug.ch wrote:
>On 05/12/16 at 01:48pm, Jiri Pirko wrote:
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 12436d1..a69e418 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -7376,6 +7376,8 @@ EXPORT_SYMBOL(netdev_stats_to_stats64);
>>   *	The device driver may provide its own method by setting
>>   *	dev->netdev_ops->get_stats64 or dev->netdev_ops->get_stats;
>>   *	otherwise the internal statistics structure is used.
>> + *	If device supports both HW & SW statistics - this function should
>> + *	return the HW statistics.
>>   */
>>  struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
>>  					struct rtnl_link_stats64 *storage)
>
>Can we clarify in a comment that given HW stats are available whether this
>would continue to account for something like a memory allocation failure
>through tx_dropped (for drivers which do skb_realloc_headroom() in xmit)
>or tx_busy for when the ring is busy? HW would never see such failures Is
>the expectation that dev_get_stats() continues to include these software
>failures?

I think it makes sense to merge HW counters with the kernel error counters
you mention. We'll fix that. Thanks.
