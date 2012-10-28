From: Cyril Brulebois <kibi@debian.org>
Subject: [PATCH] r8169: Fix WoL on RTL8168d/8111d.
Date: Sun, 28 Oct 2012 03:46:54 +0100
Message-ID: <1351392414-32219-1-git-send-email-kibi@debian.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Cyril Brulebois <kibi@debian.org>
To: nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This regression was spotted between Debian squeeze and Debian wheezy
kernels (respectively based on 2.6.32 and 3.2). The fix was inspired
by <http://www.spinics.net/lists/netdev/msg178543.html>, using
RTL_GIGA_MAC_VER_{25,26} for the RTL8168d/8111d chipset.

Probable regression from d4ed95d796e5126bba51466dc07e287cebc8bd19;
more chipsets are likely affected.

Tested on top of a 3.2.23 kernel.

Reported-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Tested-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Signed-off-by: Cyril Brulebois <kibi@debian.org>
---
 drivers/net/ethernet/realtek/r8169.c |    2 ++
 1 file changed, 2 insertions(+)


It looks like RTL_GIGA_MAC_VER_{25,26} are kinda supposed to go
together so I kept both. Florent's testing gave the following results:
 - RTL_GIGA_MAC_VER_25 only: FAIL.
 - RTL_GIGA_MAC_VER_26 only: SUCCESS.
 - RTL_GIGA_MAC_VER_25 + RTL_GIGA_MAC_VER_26: SUCCESS.


diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7ff886..eb6a5e4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3827,6 +3827,8 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
 	case RTL_GIGA_MAC_VER_32:
-- 
1.7.10.4
