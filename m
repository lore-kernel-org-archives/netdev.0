From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 00/02] pull request for 'upstream-jeff' branch
Date: Tue, 6 Nov 2007 23:22:13 +0100
Message-ID: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55095 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754587AbXKFWWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 17:22:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'upstream-jeff' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff

to get the changes below.

Distance from 'master' (f2511f13daaf00fdd206bee7b108f75923a613c6)
-----------------------------------------------------------------

69b4d070ea49bd7f589776ea471a6988345eeee5
db1470271c581050dcacc6ed681b9166d30bdba0

Diffstat
--------

 drivers/net/r8169.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

Shortlog
--------

Ciaran McCreesh (1):
      r8169: add PCI ID for the 8168 in the Abit Fatal1ty F-190HD motherboard

Francois Romieu (1):
      r8169: do not enable the TBI for the 8168 and the 81x0

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b94fa7e..9dbab3f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -171,6 +171,8 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
+	{ 0x0001,				0x8168,
+		PCI_ANY_ID, 0x2410, 0, 0, RTL_CFG_2 },
 	{0,},
 };
 
@@ -1739,7 +1741,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	if (RTL_R8(PHYstatus) & TBI_Enable) {
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
+	    (RTL_R8(PHYstatus) & TBI_Enable)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
-- 
Ueimor
