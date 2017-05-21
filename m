From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 08/10] qed: Fix setting of Management bitfields
Date: Sun, 21 May 2017 12:10:59 +0300
Message-ID: <1495357860-28280-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0046.outbound.protection.outlook.com ([104.47.41.46]:35311
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752767AbdEUJMC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:12:02 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

The management firmware HSI contains masks which are already
shifted to their right place, so QED_MFW_SET_FIELD() is clearing
incorrect fields by shifting the mask by the offset.

Luckily, today we set the fields in an incrementing order [so we're
not erasing any previously set fields], but this still needs fixing.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 162cd7f..fd8cf31 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -92,7 +92,7 @@ enum qed_coalescing_mode {
 
 #define QED_MFW_SET_FIELD(name, field, value)				       \
 	do {								       \
-		(name)	&= ~((field ## _MASK) << (field ## _SHIFT));	       \
+		(name)	&= ~(field ## _MASK);	       \
 		(name)	|= (((value) << (field ## _SHIFT)) & (field ## _MASK));\
 	} while (0)
 
-- 
1.9.3
