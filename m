From: Axel Lin <axel.lin@ingics.com>
Subject: [RFT][PATCH 2/2] phy: bcm-ns2-pcie: Set missing .owner field in
 ns2_pci_phy_ops
Date: Sat, 25 Jun 2016 00:26:08 +0800
Message-ID: <1466785568.13259.2.camel@ingics.com>
References: <1466785501.13259.1.camel@ingics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pramod Kumar <pramod.kumar@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35394 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcFXQ0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 12:26:13 -0400
Received: by mail-pf0-f196.google.com with SMTP id t190so9683874pfb.2
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 09:26:13 -0700 (PDT)
In-Reply-To: <1466785501.13259.1.camel@ingics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing .owner field in ns2_pci_phy_ops, which is used for refcounting.
While at it, also makes ns2_pci_phy_ops const as it's never modified.

Signed-off-by: Axel Lin <axel.lin@ingics.com>
---
 drivers/phy/phy-bcm-ns2-pcie.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/phy/phy-bcm-ns2-pcie.c b/drivers/phy/phy-bcm-ns2-pcie.c
index ee61772..4c7d11d 100644
--- a/drivers/phy/phy-bcm-ns2-pcie.c
+++ b/drivers/phy/phy-bcm-ns2-pcie.c
@@ -47,8 +47,9 @@ err:
 	return rc;
 }
 
-static struct phy_ops ns2_pci_phy_ops = {
+static const struct phy_ops ns2_pci_phy_ops = {
 	.init = ns2_pci_phy_init,
+	.owner = THIS_MODULE,
 };
 
 static int ns2_pci_phy_probe(struct mdio_device *mdiodev)
-- 
2.5.0
