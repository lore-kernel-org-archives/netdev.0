From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3 for 3.18] rtlwifi: rtl8192ce: Fix missing interrupt ready flag
Date: Fri, 28 Nov 2014 10:41:16 -0600
Message-ID: <1417192876-12101-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1417192876-12101-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Catalin Iacob <iacobcatalin@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:60128 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbaK1Ql2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 11:41:28 -0500
In-Reply-To: <1417192876-12101-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proper operation with the rewritten PCI mini driver requires that a flag be set
when interrupts are enabled. This flag was missed.  This patch is one of three needed to
fix the kernel regression reported at https://bugzilla.kernel.org/show_bug.cgi?id=88951.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Catalin Iacob <iacobcatalin@gmail.com>
Tested-by: Catalin Iacob <iacobcatalin@gmail.com>
Cc: Catalin Iacob <iacobcatalin@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 55357d6..d2ec516 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1287,6 +1287,7 @@ void rtl92ce_enable_interrupt(struct ieee80211_hw *hw)
 
 	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
 	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
+	rtlpci->irq_enabled = true;
 }
 
 void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
@@ -1296,7 +1297,7 @@ void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
 
 	rtl_write_dword(rtlpriv, REG_HIMR, IMR8190_DISABLED);
 	rtl_write_dword(rtlpriv, REG_HIMRE, IMR8190_DISABLED);
-	synchronize_irq(rtlpci->pdev->irq);
+	rtlpci->irq_enabled = false;
 }
 
 static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
-- 
2.1.2
