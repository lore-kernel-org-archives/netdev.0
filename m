From: Sergio Luis <sergio@uece.br>
Subject: [PATCH] drivers/net/sis190: fix section mismatch warning in sis190_get_mac_addr
Date: Sun, 10 Feb 2008 17:56:25 -0300
Message-ID: <47AF64F9.1000203@uece.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755864AbYBJUzs@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix following warnings:
WARNING: drivers/net/sis190.o(.text+0x103): Section mismatch in reference from the function sis190_get_mac_addr() to the function .devinit.text:sis190_get_mac_addr_from_apc()
WARNING: drivers/net/sis190.o(.text+0x10e): Section mismatch in reference from the function sis190_get_mac_addr() to the function .devinit.text:sis190_get_mac_addr_from_eeprom()

Annotate sis190_get_mac_addr() with __devinit.

Signed-off-by: Sergio Luis <sergio@uece.br>

 sis190.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -urN linux-2.6.24-git22.orig/drivers/net/sis190.c linux-2.6.24-git22/drivers/net/sis190.c
--- linux-2.6.24-git22.orig/drivers/net/sis190.c	2008-02-10 16:56:37.000000000 -0300
+++ linux-2.6.24-git22/drivers/net/sis190.c	2008-02-10 17:38:36.000000000 -0300
@@ -1630,7 +1630,8 @@
 	SIS_PCI_COMMIT();
 }
 
-static int sis190_get_mac_addr(struct pci_dev *pdev, struct net_device *dev)
+static int __devinit sis190_get_mac_addr(struct pci_dev *pdev, 
+					 struct net_device *dev)
 {
 	u8 from;
 
