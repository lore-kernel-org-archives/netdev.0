From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 5/5] r8169: oversized driver field for ethtool
Date: Tue, 7 Dec 2004 01:22:08 +0100
Message-ID: <20041207002208.GA18910@electric-eye.fr.zoreil.com>
References: <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041205235519.GA21885@lilah.hetzel.org> <20041205233756.GB29236@electric-eye.fr.zoreil.com> <20041207001419.GB12838@electric-eye.fr.zoreil.com> <20041207001535.GA18672@electric-eye.fr.zoreil.com> <20041207001621.GB18672@electric-eye.fr.zoreil.com> <20041207001722.GC18672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com,
        Dorn Hetzel <kernel@dorn.hetzel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20041207001722.GC18672@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reported by Richard Dawe <rich@phekda.gotadsl.co.uk>:
- RTL8169_DRIVER_NAME contains more than the 32 characters allowed for the
  driver field;
- remove RTL8169_DRIVER_NAME as it is only used once.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-280 drivers/net/r8169.c
--- linux-2.6.10-rc2/drivers/net/r8169.c~r8169-280	2004-12-07 00:56:46.864676094 +0100
+++ linux-2.6.10-rc2-fr/drivers/net/r8169.c	2004-12-07 00:57:11.031721347 +0100
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
