From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] net: Add classid to sk_buff.
Date: Wed, 19 May 2010 19:55:38 -0700 (PDT)
Message-ID: <20100519.195538.139536660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: bmb@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753285Ab0ETCz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 22:55:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We make this zero cost by moving queue_mapping into an existing
empty __u16 slot.  Thus making a __u32 available, which we use
for the 'classid'.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7c16f24..f847ec2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -367,12 +367,9 @@ struct sk_buff {
 #ifdef CONFIG_NET_CLS_ACT
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
+	__u32			classid;
 #endif
 
-	__u16			queue_mapping;
-
-	/* 16 bit hole */
-
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
 #endif
@@ -385,6 +382,7 @@ struct sk_buff {
 	};
 
 	__u16			vlan_tci;
+	__u16			queue_mapping;
 
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
-- 
1.7.0.4

