From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 1/3] KS8851: Add soft reset at probe time
Date: Tue, 20 Oct 2009 10:49:03 +0100
Message-ID: <20091020094954.310595275@fluff.org.uk>
References: <20091020094902.274646871@fluff.org.uk>
Cc: Ping.Doong@Micrel.Com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:50627 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751701AbZJTJtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 05:49:52 -0400
Content-Disposition: inline; filename=ks8851-reset-at-probe.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issue a full soft reset at probe time.

This was reported by Doong Ping of Micrel, but no explanation of why this
is necessary or what bug it is fixing. Add it as it does not seem to hurt
the current driver and ensures that the device is in a known state when we
start setting it up.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
 drivers/net/ks8851.c |    3 +++
 1 file changed, 3 insertions(+)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2009-10-12 23:04:15.000000000 +0100
+++ b/drivers/net/ks8851.c	2009-10-13 13:28:43.000000000 +0100
@@ -1239,6 +1239,9 @@ static int __devinit ks8851_probe(struct
 	ndev->netdev_ops = &ks8851_netdev_ops;
 	ndev->irq = spi->irq;
 
+	/* issue a global soft reset to reset the device. */
+	ks8851_soft_reset(ks, GRR_GSR);
+
 	/* simple check for a valid chip being connected to the bus */
 
 	if ((ks8851_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {

