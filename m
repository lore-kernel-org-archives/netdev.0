From: Ingo Molnar <mingo@elte.hu>
Subject: [patch, -rc5-mm1] lock validator: special locking: net/ipv4/igmp.c #2
Date: Thu, 1 Jun 2006 08:35:37 +0200
Message-ID: <20060601063537.GA19931@elte.hu>
References: <4807377b0605311704g44fe10f1oc54315276890071@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Linux-Kernel," <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	NetDEV list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:17645 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S965297AbWFAGfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 02:35:17 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0605311704g44fe10f1oc54315276890071@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:

> well, when running e1000 through some code paths on FC4 + 
> 2.6.17-rc5-mm1 + ingo's latest rollup patch, with this lockdep debug 
> option enabled I got this:
> 
> e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
> 
> ======================================
> [ BUG: bad unlock ordering detected! ]
> --------------------------------------
> mDNSResponder/2361 is trying to release lock (&in_dev->mc_list_lock) at:
> [<ffffffff81233f5a>] ip_mc_add_src+0x85/0x1f8

ok, could you try the patch below? (i also updated the rollup with this 
fix)

	Ingo

---------------------
Subject: lock validator: special locking: net/ipv4/igmp.c #2
From: Ingo Molnar <mingo@elte.hu>

another case of non-nested unlocking igmp.c.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 net/ipv4/igmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/net/ipv4/igmp.c
===================================================================
--- linux.orig/net/ipv4/igmp.c
+++ linux/net/ipv4/igmp.c
@@ -1646,7 +1646,7 @@ static int ip_mc_add_src(struct in_devic
 		return -ESRCH;
 	}
 	spin_lock_bh(&pmc->lock);
-	read_unlock(&in_dev->mc_list_lock);
+	read_unlock_non_nested(&in_dev->mc_list_lock);
 
 #ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);
