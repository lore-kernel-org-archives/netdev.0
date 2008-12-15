From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 9/9] irda: Fix irda_skb_cb size
Date: Mon, 15 Dec 2008 02:57:38 +0100
Message-ID: <20081215015904.915013041@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:37899 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751799AbYLOCDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:15 -0500
Content-Disposition: inline; filename=0009-irda-Fix-irda_skb_cb-size.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we're stuffing an irda_skb_cb structure in front of the skb->data,
having sizeof(irda_skb_cb) as a multiple of 4 would be a lot nicer.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irda_device.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 28c690c..71c07ce 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -146,7 +146,7 @@ struct irda_skb_cb {
 	void    *context;    /* May be used by drivers */
 	void    (*destructor)(struct sk_buff *skb); /* Used for flow control */
 	__u16   xbofs_delay; /* Number of xbofs used for generating the mtt */
-	__u8    line;        /* Used by IrCOMM in IrLPT mode */
+	__u32   line;        /* Used by IrCOMM in IrLPT mode */
 };
 
 /* Chip specific info */
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
