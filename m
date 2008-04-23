From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] ibm_newemac: Increase MDIO timeouts
Date: Wed, 23 Apr 2008 15:17:14 +1000
Message-ID: <20080423051832.63BF7DDF65@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<super.firetwister@googlemail.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37532 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbYDWFSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 01:18:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch doubles the MDIO timeouts in EMAC as there are field
cases where they are two short to communicate with some PHYs.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/core.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-04-23 15:11:16.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-04-23 15:14:20.000000000 +1000
@@ -738,7 +738,7 @@ static int __emac_mdio_read(struct emac_
 		rgmii_get_mdio(dev->rgmii_dev, dev->rgmii_port);
 
 	/* Wait for management interface to become idle */
-	n = 10;
+	n = 20;
 	while (!emac_phy_done(dev, in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n) {
@@ -763,7 +763,7 @@ static int __emac_mdio_read(struct emac_
 	out_be32(&p->stacr, r);
 
 	/* Wait for read to complete */
-	n = 100;
+	n = 200;
 	while (!emac_phy_done(dev, (r = in_be32(&p->stacr)))) {
 		udelay(1);
 		if (!--n) {
@@ -810,7 +810,7 @@ static void __emac_mdio_write(struct ema
 		rgmii_get_mdio(dev->rgmii_dev, dev->rgmii_port);
 
 	/* Wait for management interface to be idle */
-	n = 10;
+	n = 20;
 	while (!emac_phy_done(dev, in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n) {
@@ -836,7 +836,7 @@ static void __emac_mdio_write(struct ema
 	out_be32(&p->stacr, r);
 
 	/* Wait for write to complete */
-	n = 100;
+	n = 200;
 	while (!emac_phy_done(dev, in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n) {
