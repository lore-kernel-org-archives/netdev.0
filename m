From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] net: sched: fix NULL pointer dereference when
 action calls some targets
Date: Fri, 18 Aug 2017 16:26:21 -0700 (PDT)
Message-ID: <20170818.162621.1683418805843691765.davem@davemloft.net>
References: <f9e3e9338eeb819c40efb13fed33514a3df23c14.1503025296.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        pablo@netfilter.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbdHRX0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:26:22 -0400
In-Reply-To: <f9e3e9338eeb819c40efb13fed33514a3df23c14.1503025296.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 18 Aug 2017 11:01:36 +0800

> As we know in some target's checkentry it may dereference par.entryinfo
> to check entry stuff inside. But when sched action calls xt_check_target,
> par.entryinfo is set with NULL. It would cause kernel panic when calling
> some targets.
> 
> It can be reproduce with:
>   # tc qd add dev eth1 ingress handle ffff:
>   # tc filter add dev eth1 parent ffff: u32 match u32 0 0 action xt \
>     -j ECN --ecn-tcp-remove
> 
> It could also crash kernel when using target CLUSTERIP or TPROXY.
> 
> By now there's no proper value for par.entryinfo in ipt_init_target,
> but it can not be set with NULL. This patch is to void all these
> panics by setting it with an ipt_entry obj with all members = 0.
> 
> Note that this issue has been there since the very beginning.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
