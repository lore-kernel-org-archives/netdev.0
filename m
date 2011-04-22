From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: [PATCH] netfilter/IPv6:  fix DSCP mangle code
Date: Fri, 22 Apr 2011 16:02:39 +0900
Message-ID: <1303455759.2023.39.camel@nausicaa>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, jengelh@medozas.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:58889 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab1DVH0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 03:26:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mask indicates the bits one wants to zero out, so it needs to be
inverted before applying to the original TOS field.

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-2.6.37-orig/net/netfilter/xt_DSCP.c linux-2.6.37/net/netfilter/xt_DSCP.c
--- linux-2.6.37-orig/net/netfilter/xt_DSCP.c	2011-01-05 09:50:19.000000000 +0900
+++ linux-2.6.37/net/netfilter/xt_DSCP.c	2011-04-21 16:01:25.801890733 +0900
@@ -99,7 +99,7 @@ tos_tg6(struct sk_buff *skb, const struc
 	u_int8_t orig, nv;
 
 	orig = ipv6_get_dsfield(iph);
-	nv   = (orig & info->tos_mask) ^ info->tos_value;
+	nv   = (orig & ~info->tos_mask) ^ info->tos_value;
 
 	if (orig != nv) {
 		if (!skb_make_writable(skb, sizeof(struct iphdr)))


