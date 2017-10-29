From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: avoid matching qdisc with zero handle
Date: Sun, 29 Oct 2017 17:56:12 +0900 (KST)
Message-ID: <20171029.175612.604448910357209585.davem@davemloft.net>
References: <20171028050856.18393-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dcaratti@redhat.com, jkosina@suse.cz,
        edumazet@google.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdJ2I4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 04:56:16 -0400
In-Reply-To: <20171028050856.18393-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 27 Oct 2017 22:08:56 -0700

> Davide found the following script triggers a NULL pointer
> dereference:
> 
> ip l a name eth0 type dummy
> tc q a dev eth0 parent :1 handle 1: htb
> 
> This is because for a freshly created netdevice noop_qdisc
> is attached and when passing 'parent :1', kernel actually
> tries to match the major handle which is 0 and noop_qdisc
> has handle 0 so is matched by mistake. Commit 69012ae425d7
> tries to fix a similar bug but still misses this case.
> 
> Handle 0 is not a valid one, should be just skipped. In
> fact, kernel uses it as TC_H_UNSPEC.
> 
> Fixes: 69012ae425d7 ("net: sched: fix handling of singleton qdiscs with qdisc_hash")
> Fixes: 59cc1f61f09c ("net: sched:convert qdisc linked list to hashtable")
> Reported-by: Davide Caratti <dcaratti@redhat.com>
> Cc: Jiri Kosina <jkosina@suse.cz>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
