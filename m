From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net] net: sched: set xt_tgchk_param par.net properly
 in ipt_init_target
Date: Tue, 08 Aug 2017 20:38:58 -0700 (PDT)
Message-ID: <20170808.203858.816888994808276335.davem@davemloft.net>
References: <7aa6e3f47ea0feb6f348b4de20fc6503e8c8e25b.1502177125.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752497AbdHIDjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 23:39:00 -0400
In-Reply-To: <7aa6e3f47ea0feb6f348b4de20fc6503e8c8e25b.1502177125.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  8 Aug 2017 15:25:25 +0800

> Now xt_tgchk_param par in ipt_init_target is a local varibale,
> par.net is not initialized there. Later when xt_check_target
> calls target's checkentry in which it may access par.net, it
> would cause kernel panic.
> 
> Jaroslav found this panic when running:
> 
>   # ip link add TestIface type dummy
>   # tc qd add dev TestIface ingress handle ffff:
>   # tc filter add dev TestIface parent ffff: u32 match u32 0 0 \
>     action xt -j CONNMARK --set-mark 4
> 
> This patch is to pass net param into ipt_init_target and set
> par.net with it properly in there.
> 
> v1->v2:
>   As Wang Cong pointed, I missed ipt_net_id != xt_net_id, so fix
>   it by also passing net_id to __tcf_ipt_init.
> v2->v3:
>   Missed the fixes tag, so add it.
> 
> Fixes: ecb2421b5ddf ("netfilter: add and use nf_ct_netns_get/put")
> Reported-by: Jaroslav Aster <jaster@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
