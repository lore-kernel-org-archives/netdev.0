From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'jg-20061012-00' tag
Date: Thu, 12 Oct 2006 22:30:46 +0200
Message-ID: <20061012203046.GA7227@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	hchacha@users.sourceforge.net, Arnaud Patard <apatard@mandriva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52138 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750783AbWJLUbP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 16:31:15 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag 'jg-20061012-00' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git jg-20061012-00

to get the changes below.

Distance from 'upstream-fixes'
-----------------------------

733b736c91dd2c556f35dffdcf77e667cf10cefc
73f5e28b336772c4b08ee82e5bf28ab872898ee1

Diffstat
--------

 drivers/net/r8169.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

Shortlog
--------

Andrew Morton:
      r8169: PCI ID for Corega Gigabit network card

Arnaud Patard:
      r8169: fix infinite loop during hotplug

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4c47c5b..c2c9a86 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -214,6 +214,7 @@ static struct pci_device_id rtl8169_pci_
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
+	{ PCI_DEVICE(0x1259,			0xc107), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
@@ -2701,6 +2702,7 @@ static void rtl8169_down(struct net_devi
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int poll_locked = 0;
+	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
@@ -2739,8 +2741,11 @@ core_down:
 	 * 2) dev->change_mtu
 	 *    -> rtl8169_poll can not be issued again and re-enable the
 	 *       interruptions. Let's simply issue the IRQ down sequence again.
+	 *
+	 * No loop if hotpluged or major error (0xffff).
 	 */
-	if (RTL_R16(IntrMask))
+	intrmask = RTL_R16(IntrMask);
+	if (intrmask && (intrmask != 0xffff))
 		goto core_down;
 
 	rtl8169_tx_clear(tp);
-- 
Ueimor
