From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/2] staging: r8822be: Remove some dead code
Date: Wed, 30 Aug 2017 14:43:12 -0500
Message-ID: <20170830194313.9659-2-Larry.Finger@lwfinger.net>
References: <20170830194313.9659-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 netdev@vger.kernel.org, Birming Chiu <birming@realtek.com>,
 Steven Ting <steventing@realtek.com>, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170830194313.9659-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The code found inside an #ifdef CONFIG_RTL_DEBUG ... #endif section
is left over from debugging of the original driver, and should be
deleted.

Reported by: Andreas Ziegler <andreas.ziegler@fau.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Ping-Ke Shih <pkshih@realtek.com>
Cc: Yan-Hsuan Chuang <yhchuang@realtek.com>
Cc: Birming Chiu <birming@realtek.com>
Cc: Shaofu <shaofu@realtek.com>
Cc: Steven Ting <steventing@realtek.com>
---
 drivers/staging/rtlwifi/halmac/rtl_halmac.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/drivers/staging/rtlwifi/halmac/rtl_halmac.c b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
index 031bf2c6078f..2b1c5fae64ef 100644
--- a/drivers/staging/rtlwifi/halmac/rtl_halmac.c
+++ b/drivers/staging/rtlwifi/halmac/rtl_halmac.c
@@ -386,26 +386,6 @@ static void deinit_priv(struct rtl_halmac *halmac)
 		u32 count, size;
 
 		count = HALMAC_FEATURE_ALL + 1;
-#ifdef CONFIG_RTL_DEBUG
-		{
-			struct submit_ctx *sctx;
-			u32 i;
-
-			for (i = 0; i < count; i++) {
-				if (!indicator[i].sctx)
-					continue;
-
-				RT_TRACE(
-					rtlpriv, COMP_HALMAC, DBG_LOUD,
-					"%s: <WARN> %s id(%d) sctx still exist!!\n",
-					__func__, RTL_HALMAC_FEATURE_NAME[i],
-					i);
-				sctx = indicator[i].sctx;
-				indicator[i].sctx = NULL;
-				rtl_mfree((u8 *)sctx, sizeof(*sctx));
-			}
-		}
-#endif /* !CONFIG_RTL_DEBUG */
 		size = sizeof(*indicator) * count;
 		kfree((u8 *)indicator);
 	}
-- 
2.12.3
