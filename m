From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2] staging: r8822be: Simplify deinit_priv()
Date: Wed, 30 Aug 2017 14:43:13 -0500
Message-ID: <20170830194313.9659-3-Larry.Finger@lwfinger.net>
References: <20170830194313.9659-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Ping-Ke Shih <pkshih@realtek.com>,
        Yan-Hsuan Chuang <yhchuang@realtek.com>,
        Birming Chiu <birming@realtek.com>,
        Shaofu <shaofu@realtek.com>, Steven Ting <steventing@realtek.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35686 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbdH3TnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 15:43:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id k77so6471392oib.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 12:43:20 -0700 (PDT)
In-Reply-To: <20170830194313.9659-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the extraneous debugging code is removed, routine deinit_priv()
clearly contains code that serves no useful purpose.

A null test before a call to kfree() and a spurious cast are also removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Ping-Ke Shih <pkshih@realtek.com>
Cc: Yan-Hsuan Chuang <yhchuang@realtek.com>
Cc: Birming Chiu <birming@realtek.com>
Cc: Shaofu <shaofu@realtek.com>
Cc: Steven Ting <steventing@realtek.com>
---
 drivers/staging/rtlwifi/halmac/rtl_halmac.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/staging/rtlwifi/halmac/rtl_halmac.c b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
index 2b1c5fae64ef..6448a8bfc14b 100644
--- a/drivers/staging/rtlwifi/halmac/rtl_halmac.c
+++ b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
@@ -382,13 +382,7 @@ static void deinit_priv(struct rtl_halmac *halmac)
 
 	indicator = halmac->indicator;
 	halmac->indicator = NULL;
-	if (indicator) {
-		u32 count, size;
-
-		count = HALMAC_FEATURE_ALL + 1;
-		size = sizeof(*indicator) * count;
-		kfree((u8 *)indicator);
-	}
+	kfree(indicator);
 }
 
 int rtl_halmac_init_adapter(struct rtl_priv *rtlpriv)
-- 
2.12.3
