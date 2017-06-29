From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sched: Fix one possible panic when no
 destroy callback
Date: Thu, 29 Jun 2017 12:55:40 -0400 (EDT)
Message-ID: <20170629.125540.1645522320014274592.davem@davemloft.net>
References: <1498625634-115351-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751941AbdF2Qzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:55:42 -0400
In-Reply-To: <1498625634-115351-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Wed, 28 Jun 2017 12:53:54 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> When qdisc fail to init, qdisc_create would invoke the destroy callback
> to cleanup. But there is no check if the callback exists really. So it
> would cause the panic if there is no real destroy callback like the qdisc
> codel, fq, and so on.
> 
> Take codel as an example following:
> When a malicious user constructs one invalid netlink msg, it would cause
> codel_init->codel_change->nla_parse_nested failed.
> Then kernel would invoke the destroy callback directly but qdisc codel
> doesn't define one. It causes one panic as a result.
> 
> Now add one the check for destroy to avoid the possible panic.
> 
> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied and queued up for -stable.
