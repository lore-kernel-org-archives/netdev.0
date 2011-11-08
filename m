From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: more driver shutdown WoL regression.
Date: Tue, 8 Nov 2011 23:35:02 +0100
Message-ID: <20111108223502.GA20437@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Becker <chemobejk@gmail.com>,
	David Miller <davem@davemloft.net>,
	Hayes <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45185 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926Ab1KHWjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:39:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Almost the same narrative as 649b3b8c4e8681de443b4dc9e387c3036369e02e
but with more experimental data.

Stefan Becker has reported that the same kind of fix as the one
introduced in 649b3b8c4e8681de443b4dc9e387c3036369e02e ("r8169: fix
driver shutdown WoL regression") before 3.1 was released is required
for his 8168c (RTL_GIGA_MAC_VER_22).

I have tested a few chipsets as well:
- without patch, shutdown + WoL works fine for :
  o RTL_GIGA_MAC_VER_30 (8105e and 8105evc)
  o RTL_GIGA_MAC_VER_33 (8168ed)
  o RTL_GIGA_MAC_VER_34 (8168evl)
  o RTL_GIGA_MAC_VER_35 (8168f)
  o RTL_GIGA_MAC_VER_06 (plain old PCI 8169sc)
- without patch, shutdown + WoL is broken with :
  o RTL_GIGA_MAC_VER_26 (8168d-vb-gr)
  o RTL_GIGA_MAC_VER_25 (8168d-gr)
  o RTL_GIGA_MAC_VER_12 (8168b)
  o RTL_GIGA_MAC_VER_09 (both 8102e-vb-gr and 8103e-gr)

I have widened rtl_wol_suspend_quirk a bit beyond those data to include
a broader subset of chipsets from the same families, thus including the
8168cp and 8168dp.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Stefan Becker <chemobejk@gmail.com>
Cc: Hayes <hayeswang@realtek.com>
---

 Hayes, any insight ?

 drivers/net/ethernet/realtek/r8169.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 92b45f0..829674d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3496,6 +3496,18 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+	case RTL_GIGA_MAC_VER_19:
+	case RTL_GIGA_MAC_VER_20:
+	case RTL_GIGA_MAC_VER_21:
+	case RTL_GIGA_MAC_VER_22:
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
 	case RTL_GIGA_MAC_VER_29:
 	case RTL_GIGA_MAC_VER_30:
 	case RTL_GIGA_MAC_VER_32:
-- 
1.7.6.4
