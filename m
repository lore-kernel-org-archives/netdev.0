From: akpm@osdl.org
Subject: [patch 09/10] r8169: oversized driver field for ethtool
Date: Tue, 04 Jan 2005 21:59:35 -0800
Message-ID: <200501050559.j055xi614722@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org,
        romieu@fr.zoreil.com, rich@phekda.gotadsl.co.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Francois Romieu <romieu@fr.zoreil.com>

Reported by Richard Dawe <rich@phekda.gotadsl.co.uk>:
- RTL8169_DRIVER_NAME contains more than the 32 characters allowed for the
  driver field;
- remove RTL8169_DRIVER_NAME as it is only used once.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/r8169.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/r8169.c~r8169-oversized-driver-field-for-ethtool drivers/net/r8169.c
--- 25/drivers/net/r8169.c~r8169-oversized-driver-field-for-ethtool	2005-01-04 21:57:36.451592800 -0800
+++ 25-akpm/drivers/net/r8169.c	2005-01-04 21:57:36.455592192 -0800
@@ -63,7 +63,6 @@ VERSION 1.6LK	<2004/04/14>
 
 #define RTL8169_VERSION "1.6LK"
 #define MODULENAME "r8169"
-#define RTL8169_DRIVER_NAME   MODULENAME " Gigabit Ethernet driver " RTL8169_VERSION
 #define PFX MODULENAME ": "
 
 #ifdef RTL8169_DEBUG
@@ -564,8 +563,8 @@ static void rtl8169_get_drvinfo(struct n
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	strcpy(info->driver, RTL8169_DRIVER_NAME);
-	strcpy(info->version, RTL8169_VERSION );
+	strcpy(info->driver, MODULENAME);
+	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
 }
 
@@ -1282,7 +1281,8 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	board_idx++;
 
 	if (!printed_version) {
-		printk(KERN_INFO RTL8169_DRIVER_NAME " loaded\n");
+		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
+		       MODULENAME, RTL8169_VERSION);
 		printed_version = 1;
 	}
 
_
