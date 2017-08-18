From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 net] net: sched: fix NULL pointer dereference when
 action calls some targets
Date: Fri, 18 Aug 2017 10:29:34 +0200
Message-ID: <20170818082934.GA1406@salvia>
References: <f9e3e9338eeb819c40efb13fed33514a3df23c14.1503025296.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:56803 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdHRIaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:30:03 -0400
Content-Disposition: inline
In-Reply-To: <f9e3e9338eeb819c40efb13fed33514a3df23c14.1503025296.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 11:01:36AM +0800, Xin Long wrote:
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

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
