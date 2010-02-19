From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/03: nf_queue: fix NF_STOLEN skb leak
Date: Fri, 19 Feb 2010 18:02:10 +0100 (MET)
Message-ID: <20100219170210.18096.32795.sendpatchset@x2.localnet>
References: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62759 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab0BSRCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 12:02:11 -0500
In-Reply-To: <20100219170206.18096.12788.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 64507fdbc29c3a622180378210ecea8659b14e40
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Fri Feb 19 15:28:38 2010 +0100

    netfilter: nf_queue: fix NF_STOLEN skb leak
    
    commit 3bc38712e3a6e059 (handle NF_STOP and unknown verdicts in
    nf_reinject) was a partial fix to packet leaks.
    
    If user asks NF_STOLEN status, we must free the skb as well.
    
    Reported-by: Afi Gjermund <afigjermund@gmail.com>
    Signed-off-by: Eric DUmazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 3a6fd77..ba095fd 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -265,7 +265,6 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 		local_bh_disable();
 		entry->okfn(skb);
 		local_bh_enable();
-	case NF_STOLEN:
 		break;
 	case NF_QUEUE:
 		if (!__nf_queue(skb, elem, entry->pf, entry->hook,
@@ -273,6 +272,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 				verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 		break;
+	case NF_STOLEN:
 	default:
 		kfree_skb(skb);
 	}
