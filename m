From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] r8169: enforce RX_MULTI_EN on rtl8168ep/8111ep chips
Date: Tue,  4 Aug 2015 22:11:43 +0200
Message-ID: <1438719103-22067-1-git-send-email-ivecera@redhat.com>
Cc: alexander@bitspace.se, nic_swsd@realtek.com, romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbbHDULs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 16:11:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enforcing this flag in RxConfig for the mentioned chips fixes netdev
watchdog issues prepended with AMD IOMMU message(s) like:
AMD-Vi: Event logged [IO_PAGE_FAULT device=01:00.0 domain=0x001d address=0x0000000000003000 flags=0x0050]

Note that this flag is also set in Realtek's own driver for these chips.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
Tested-by: Alexander Lindqvist <alexander@bitspace.se>
---
 drivers/net/ethernet/realtek/r8169.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..f790f61 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4875,10 +4875,12 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_46:
 	case RTL_GIGA_MAC_VER_47:
 	case RTL_GIGA_MAC_VER_48:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
+		break;
 	case RTL_GIGA_MAC_VER_49:
 	case RTL_GIGA_MAC_VER_50:
 	case RTL_GIGA_MAC_VER_51:
-		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
+		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST | RX_EARLY_OFF);
 		break;
 	default:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST);
-- 
2.4.6
