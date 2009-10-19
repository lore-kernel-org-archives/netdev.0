From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Fix struct inet_timewait_sock bitfield annotation
Date: Mon, 19 Oct 2009 10:48:51 +0200
Message-ID: <4ADC27F3.5050508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57282 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbZJSIsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 04:48:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9e337b0f (net: annotate inet_timewait_sock bitfields)
added 4/8 bytes in struct inet_timewait_sock.

Fix this by declaring tw_ipv6_offset in the 'flags' bitfield
The 14 bits hole is named tw_pad to make it cleary apparent.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 37f3aea..b5ad469 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -130,11 +130,11 @@ struct inet_timewait_sock {
 	__u16			tw_num;
 	kmemcheck_bitfield_begin(flags);
 	/* And these are ours. */
-	__u8			tw_ipv6only:1,
-				tw_transparent:1;
-	/* 14 bits hole, try to pack */
+	unsigned int		tw_ipv6only     : 1,
+				tw_transparent  : 1,
+				tw_pad		: 14,	/* 14 bits hole */
+				tw_ipv6_offset  : 16;
 	kmemcheck_bitfield_end(flags);
-	__u16			tw_ipv6_offset;
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
