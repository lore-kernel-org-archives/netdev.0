From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Wed, 05 May 2010 07:24:09 +0200
Message-ID: <1273037049.2304.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:51296 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755047Ab0EEFYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 01:24:15 -0400
Received: by bwz25 with SMTP id 25so2674742bwz.28
        for <netdev@vger.kernel.org>; Tue, 04 May 2010 22:24:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eth_type_trans() & get_rps_cpus() currently need two 64bytes cache lines
in packet to compute rxhash.

Increasing NET_SKB_PAD from 32 to 64 reduces the need to one cache line
only, and makes RPS faster.

NET_IP_ALIGN(2) + ethernet_header(14) + IP_header(20/40) + ports(8)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 746a652..fe5798b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1356,9 +1356,12 @@ static inline int skb_network_offset(const struct sk_buff *skb)
  *
  * Various parts of the networking layer expect at least 32 bytes of
  * headroom, you should not reduce this.
+ * With RPS, we raised NET_SKB_PAD to 64 so that get_rps_cpus() fetches span
+ * a 64 bytes aligned block to fit modern (>= 64 bytes) cache line sizes
+ * NET_IP_ALIGN(2) + ethernet_header(14) + IP_header(20/40) + ports(8)
  */
 #ifndef NET_SKB_PAD
-#define NET_SKB_PAD	32
+#define NET_SKB_PAD	64
 #endif
 
 extern int ___pskb_trim(struct sk_buff *skb, unsigned int len);


