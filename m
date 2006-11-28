From: Ralf Baechle <ralf@linux-mips.org>
Subject: [SAA9730] Fix build error
Date: Tue, 28 Nov 2006 17:32:59 +0000
Message-ID: <20061128173259.GA19092@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:13711 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S935939AbWK1RdM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 12:33:12 -0500
Received: from localhost.localdomain ([127.0.0.1]:26784 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20040216AbWK1RdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 17:33:10 +0000
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Confusingly NET_PCI is also set for for non-PCI EISA configurations where
building this driver will result in a build error due to a reference to
pci_release_regions.

While at it, remove the EXPERIMENTAL - in all its uglyness and despite
the sincerest attempts of the buggy hardware the driver is known to work
and limit the driver to the Atlas board - the only known system to ever
use the SAA9730 before Phillips ended the short live of the SAA9730.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4f22c8e..6b5b745 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1762,7 +1762,7 @@ config VIA_RHINE_NAPI
 
 config LAN_SAA9730
 	bool "Philips SAA9730 Ethernet support (EXPERIMENTAL)"
-	depends on NET_PCI && EXPERIMENTAL && MIPS
+	depends on NET_PCI && PCI && MIPS_ATLAS
 	help
 	  The SAA9730 is a combined multimedia and peripheral controller used
 	  in thin clients, Internet access terminals, and diskless
