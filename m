From: Alexander Strakh <strakh@ispras.ru>
Subject: [PATCH] 3c507.c: remove unused NULL pointer check
Date: Mon, 21 Dec 2009 19:23:58 +0000
Message-ID: <200912211923.58735.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Donald Becker <becker@scyld.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753368AbZLUPSw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	In driver drivers/net/3c507.c in function Iirqreturn_t el16_interrupt:
1. If in line 555 dev = NULL then we goto line 556
2. In line 556 we have null dereference because pr_err called with dev->name 
in third parameter.
 555        if (dev == NULL) {
 556                pr_err("%s: net_interrupt(): irq %d for unknown device.
\n",
 557                        dev->name, irq);
 558                return IRQ_NONE;
 559        }

Found by Linux Device Drivers Verification (Svace detector)

Remove unused NULL pointer check.

Signed-off-by: Alexander Strakh <strakh@ispras.ru>

---
diff --git a/./0000/drivers/net/3c507.c b/./moder/drivers/net/3c507.c
index fbc2311..3bfb3dd 100644
--- a/./0000/drivers/net/3c507.c
+++ b/./moder/drivers/net/3c507.c
@@ -552,12 +552,6 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 	ushort ack_cmd = 0;
 	void __iomem *shmem;
 
-	if (dev == NULL) {
-		pr_err("%s: net_interrupt(): irq %d for unknown device.\n",
-			dev->name, irq);
-		return IRQ_NONE;
-	}
-
 	ioaddr = dev->base_addr;
 	lp = netdev_priv(dev);
 	shmem = lp->base;
