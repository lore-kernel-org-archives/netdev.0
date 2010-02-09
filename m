From: Matthew Garrett <mjg@redhat.com>
Subject: [PATCH 2/2] e1000e: Don't disable jumbo frames on 82537L due to eeprom contents
Date: Tue,  9 Feb 2010 18:03:50 -0500
Message-ID: <1265756630-8093-2-git-send-email-mjg@redhat.com>
References: <1265756630-8093-1-git-send-email-mjg@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matthew Garrett <mjg@redhat.com>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:46838 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab0BIXEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 18:04:07 -0500
In-Reply-To: <1265756630-8093-1-git-send-email-mjg@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the 82537L errata, jumbo frames will work correctly if ASPM
is disabled. Since we disable ASPM on these devices, leave jumbo frames
enabled.

Signed-off-by: Matthew Garrett <mjg@redhat.com>
---
 drivers/net/e1000e/82571.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 02d67d0..2df00cc 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -381,18 +381,6 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 		if (pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
-
-	case e1000_82573:
-		if (pdev->device == E1000_DEV_ID_82573L) {
-			if (e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1,
-				       &eeprom_data) < 0)
-				break;
-			if (!(eeprom_data & NVM_WORD1A_ASPM_MASK)) {
-				adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
-				adapter->max_hw_frame_size = DEFAULT_JUMBO;
-			}
-		}
-		break;
 	default:
 		break;
 	}
-- 
1.6.6.1

