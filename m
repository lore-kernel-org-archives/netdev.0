From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Add support for D-Link 530T rev C1 (Kernel Bug 38862)
Date: Thu, 28 Jul 2011 19:18:11 -0400
Message-ID: <20110728231811.GH8562@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Len Sorensen <lsorense@csclub.uwaterloo.ca>,
	linux-kernel@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	drivers_network@kernel-bugs.osdl.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The D-Link DGE-530T rev C1 is a re-badged Realtek 8169 named DLG10028C,
unlike the previous revisions which were skge based.  It is probably
the same as the discontinued DGE-528T (0x4300) other than the PCI ID.

The PCI ID is 0x1186:0x4302.

Adding it to r8169.c where 0x1186:0x4300 is already found makes the card
be detected and work.

This fixes https://bugzilla.kernel.org/show_bug.cgi?id=38862

Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d9c650..c77286e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -239,6 +239,7 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AT,		0xc107), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,


-- 
Len Sorensen
