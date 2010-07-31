From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 19/29] LMC: Remove sc->check. We don't do such checks in drivers.
Date: Sat, 31 Jul 2010 17:05:42 +0200
Message-ID: <1280588752-9340-19-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45825 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756590Ab0GaPGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:24 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c |    9 ---------
 drivers/net/wan/lmc/var.h  |    2 --
 2 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 6698aa9..56631d4 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -575,14 +575,6 @@ static void lmc_watchdog(unsigned long data)
=20
 	spin_lock_irqsave(&sc->lock, flags);
=20
-	if (sc->check !=3D 0xBEAFCAFE) {
-		printk(KERN_ERR
-		       "LMC: Corrupt net_device struct, breaking out\n");
-		spin_unlock_irqrestore(&sc->lock, flags);
-		return;
-	}
-
-
 	/* Make sure the tx jabber and rx watchdog are off,
 	 * and the transmit and receive processes are running.
 	 */
@@ -761,7 +753,6 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	dev->tx_queue_len =3D 100;
 	sc->netdev =3D dev;
 	sc->name =3D dev->name;
-	sc->check =3D 0xBEAFCAFE;
 	dev->base_addr =3D pci_resource_start(pdev, 0);
 	dev->irq =3D pdev->irq;
 	pci_set_drvdata(pdev, dev);
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index a3e9aee..10cb70d 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -320,8 +320,6 @@ struct card {
=20
 	u8 failed_ring;			/* Failure cases */
 	u8 failed_recv_alloc;
-
-	u32 check;			/* Structure check */
 };
=20
 #define PKT_BUF_SZ		1542
--=20
1.7.1.1

