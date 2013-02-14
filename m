From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5 net-next] tg3: Fix 5762 NVRAM sizing
Date: Thu, 14 Feb 2013 14:13:40 -0800
Message-ID: <1360880022-12856-3-git-send-email-mchan@broadcom.com>
References: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
 <1360880022-12856-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4440 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934910Ab3BNV4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 16:56:31 -0500
In-Reply-To: <1360880022-12856-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't set the default size to 128K if it is 5762.  Instead, rely on the
size we obtain from NVRAM location 0xf0.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3004d69..7ac0bd0 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13883,7 +13883,8 @@ static void tg3_get_5720_nvram_info(struct tg3 *tp)
 			tp->nvram_size = TG3_NVRAM_SIZE_1MB;
 			break;
 		default:
-			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5762)
+				tp->nvram_size = TG3_NVRAM_SIZE_128KB;
 			break;
 		}
 		break;
@@ -13929,7 +13930,8 @@ static void tg3_get_5720_nvram_info(struct tg3 *tp)
 			tp->nvram_size = TG3_NVRAM_SIZE_1MB;
 			break;
 		default:
-			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5762)
+				tp->nvram_size = TG3_NVRAM_SIZE_128KB;
 			break;
 		}
 		break;
-- 
1.7.1
