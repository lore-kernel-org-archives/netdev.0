From: =?iso-8859-1?q?J=FCrgen_Schindele?= <linux@schindele.name>
Subject: [PATCH] DM9000 interrupt is hardware dependant
Date: Mon, 4 Sep 2006 22:17:08 +0200
Message-ID: <200609042217.09004.linux@schindele.name>
Reply-To: =?iso-8859-1?q?J=FCrgen_Schindele?= <linux@schindele.name>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_EnI/EEb6TQ7FFN7"
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:24782 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S965041AbWIDURO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 16:17:14 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_EnI/EEb6TQ7FFN7
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi developers,
i made a patch for an PXA270-evalboard with DM9000
ethernet contoller. The Interrupt can be high- or low-
active dependant of the wiring of the MDC-(57)pin.

Because of this hardware dependency you shoud be able
to configure this behaviour in "struct resource dm9000_resources[]"

Please comment an review my patch which is attached here

Thanksalot
J=FCrgen Schindele

--Boundary-00=_EnI/EEb6TQ7FFN7
Content-Type: text/x-diff;
  charset="us-ascii";
  name="trizeps4_dm9000.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="trizeps4_dm9000.diff"

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 24996da..0a71f7b 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -598,10 +598,11 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned long sa_flags = resource_sa_flags(db->irq_res);
 
 	PRINTK2("entering dm9000_open\n");
 
-	if (request_irq(dev->irq, &dm9000_interrupt, SA_SHIRQ, dev->name, dev))
+	if (request_irq(dev->irq, &dm9000_interrupt, SA_SHIRQ | sa_flags, dev->name, dev))
 		return -EAGAIN;
 
 	/* Initialize DM9000 board */
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index cd6bd00..2eebd91 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -54,6 +54,12 @@ #define IORESOURCE_IRQ_LOWEDGE		(1<<1)
 #define IORESOURCE_IRQ_HIGHLEVEL	(1<<2)
 #define IORESOURCE_IRQ_LOWLEVEL		(1<<3)
 
+/* this macro gets back SA_TRIGGER_* bits
+ * defined in include/linux/signal.h from
+ * resource->flags which are the same as 
+ * IORESOURCE_IRQ_* bits */
+#define resource_sa_flags(res)		((res)->flags & 0xf)
+
 /* ISA PnP DMA specific bits (IORESOURCE_BITS) */
 #define IORESOURCE_DMA_TYPE_MASK	(3<<0)
 #define IORESOURCE_DMA_8BIT		(0<<0)

--Boundary-00=_EnI/EEb6TQ7FFN7--
