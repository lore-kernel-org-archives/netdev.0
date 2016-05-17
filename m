From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Tue, 17 May 2016 07:42:22 -0700
Message-ID: <573B2DCE.9030907@cumulusnetworks.com>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us> <1463053730-14991-2-git-send-email-jiri@resnulli.us> <20160517083908.GA13823@pox.localdomain> <20160517084145.GA2057@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32952 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbcEQOm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 10:42:26 -0400
Received: by mail-pf0-f176.google.com with SMTP id 206so7705494pfu.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 07:42:25 -0700 (PDT)
In-Reply-To: <20160517084145.GA2057@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/17/16, 1:41 AM, Jiri Pirko wrote:
> Tue, May 17, 2016 at 10:39:08AM CEST, tgraf@suug.ch wrote:
>> On 05/12/16 at 01:48pm, Jiri Pirko wrote:
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 12436d1..a69e418 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -7376,6 +7376,8 @@ EXPORT_SYMBOL(netdev_stats_to_stats64);
>>>   *	The device driver may provide its own method by setting
>>>   *	dev->netdev_ops->get_stats64 or dev->netdev_ops->get_stats;
>>>   *	otherwise the internal statistics structure is used.
>>> + *	If device supports both HW & SW statistics - this function should
>>> + *	return the HW statistics.
>>>   */
>>>  struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
>>>  					struct rtnl_link_stats64 *storage)
>> Can we clarify in a comment that given HW stats are available whether this
>> would continue to account for something like a memory allocation failure
>> through tx_dropped (for drivers which do skb_realloc_headroom() in xmit)
>> or tx_busy for when the ring is busy? HW would never see such failures Is
>> the expectation that dev_get_stats() continues to include these software
>> failures?
> I think it makes sense to merge HW counters with the kernel error counters
> you mention. We'll fix that. Thanks.
yep. This is what i was pointing out as well with enic and possibly other drivers.
Mellanox driver does it or not...,..the comment should definitely be fixed since
some drivers already do this.
