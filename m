From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] netfilter: avoid double free in nf_reinject
Date: Fri, 5 Aug 2011 13:36:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108051326300.1494@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Kumar Swamy <kswamy@barracuda.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35123 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754774Ab1HEKcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 06:32:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	NF_STOLEN means skb was already freed

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	May be fixes IPVS+ip_queue problem reported by Kumar Swamy:

	http://marc.info/?l=linux-virtual-server&m=131098073717449&w=2

diff -urp v3.0/linux/net/netfilter/nf_queue.c linux/net/netfilter/nf_queue.c
--- v3.0/linux/net/netfilter/nf_queue.c	2011-05-20 10:38:08.000000000 +0300
+++ linux/net/netfilter/nf_queue.c	2011-08-05 13:18:29.755962759 +0300
@@ -312,6 +312,7 @@ void nf_reinject(struct nf_queue_entry *
 		}
 		break;
 	case NF_STOLEN:
+		break;
 	default:
 		kfree_skb(skb);
 	}
