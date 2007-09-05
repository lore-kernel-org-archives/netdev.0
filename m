From: Micah Gruber <micah.gruber@gmail.com>
Subject: [PATCH] Remove unneeded pointer iph from ipcomp6_input() in net/ipv6/ipcomp6.c
Date: Wed, 05 Sep 2007 13:44:40 +0800
Message-ID: <46DE4248.6070604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756495AbXIEFnj@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This trivial patch removes the unneeded pointer iph, which is never used.

Signed-off-by: Micah Gruber < micah.gruber@gmail.com>
---

--- a/net/ipv6/ipcomp6.c	2007-09-04 23:18:43.000000000 +0800
+++ b/net/ipv6/ipcomp6.c	2007-09-05 00:48:05.000000000 +0800
@@ -65,7 +65,6 @@
 static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = -ENOMEM;
-	struct ipv6hdr *iph;
 	struct ipv6_comp_hdr *ipch;
 	int plen, dlen;
 	struct ipcomp_data *ipcd = x->data;
@@ -79,7 +78,6 @@
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Remove ipcomp header and decompress original payload */
-	iph = ipv6_hdr(skb);
 	ipch = (void *)skb->data;
 	skb->transport_header = skb->network_header + sizeof(*ipch);
 	__skb_pull(skb, sizeof(*ipch));
