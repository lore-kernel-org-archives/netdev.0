From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/7] net: Use more bit fields in napi_gro_cb
Date: Tue, 10 Feb 2015 16:30:30 -0800
Message-ID: <1423614633-25042-5-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33237 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbbBKAaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:52 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so24984705iga.1
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:51 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the free and same_flow fields to be bit fields
(2 and 1 bit sized respectively). This frees up some space for u16's.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9e9be22..43fd0a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1923,20 +1923,15 @@ struct napi_gro_cb {
 	/* Number of segments aggregated. */
 	u16	count;
 
-	/* This is non-zero if the packet may be of the same flow. */
-	u8	same_flow;
-
-	/* Free the skb? */
-	u8	free;
-#define NAPI_GRO_FREE		  1
-#define NAPI_GRO_FREE_STOLEN_HEAD 2
-
 	/* jiffies when first packet was created/queued */
 	unsigned long age;
 
 	/* Used in ipv6_gro_receive() and foo-over-udp */
 	u16	proto;
 
+	/* This is non-zero if the packet may be of the same flow. */
+	u8	same_flow:1;
+
 	/* Used in udp_gro_receive */
 	u8	udp_mark:1;
 
@@ -1946,9 +1941,16 @@ struct napi_gro_cb {
 	/* Number of checksums via CHECKSUM_UNNECESSARY */
 	u8	csum_cnt:3;
 
+	/* Free the skb? */
+	u8	free:2;
+#define NAPI_GRO_FREE		  1
+#define NAPI_GRO_FREE_STOLEN_HEAD 2
+
 	/* Used in foo-over-udp, set in udp[46]_gro_receive */
 	u8	is_ipv6:1;
 
+	/* 7 bit hole */
+
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
 
-- 
2.2.0.rc0.207.ga3a616c
