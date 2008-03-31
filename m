From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
	netif_rx()
Date: Mon, 31 Mar 2008 11:48:23 +0200
Message-ID: <20080331094823.GA11651@elte.hu>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net> <47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net> <47E6A5FD.6060407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755968AbYCaJsp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47E6A5FD.6060407@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> I noticed some paths in kernel are very stack aggressive, and on i386 
> with CONFIG_4KSTACKS we were really in a dangerous land, even without 
> my patch.
>
> What we call 4K stacks is in fact 4K - sizeof(struct task_struct), so 
> a litle bit more than 2K. [...]

that's just wrong - 4K stacks on x86 are 4K-sizeof(thread_info) - the 
task struct is allocated elsewhere. The patch below runs just fine on 
4K-stack x86.

	Ingo

------------->
Subject: net: loopback speedup
From: Ingo Molnar <mingo@elte.hu>
Date: Mon Mar 31 11:23:21 CEST 2008

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/loopback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/drivers/net/loopback.c
===================================================================
--- linux.orig/drivers/net/loopback.c
+++ linux/drivers/net/loopback.c
@@ -158,7 +158,7 @@ static int loopback_xmit(struct sk_buff 
 	lb_stats->bytes += skb->len;
 	lb_stats->packets++;
 
-	netif_rx(skb);
+	netif_receive_skb(skb);
 
 	return 0;
 }
