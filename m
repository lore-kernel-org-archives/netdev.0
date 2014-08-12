From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] rtlwifi: btcoexist: adjust double test
Date: Wed, 13 Aug 2014 01:09:29 +0530
Message-ID: <20140812193929.GA4233@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rewrite a duplicated test to test the correct value

The Coccinelle semantic patch that finds this problem is:

// <smpl>
@@
expression E;
@@

(
* E
  || ... || E
|
* E
  && ... && E
)
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
---
In file drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c, there is a
similar function that tests for WIRELESS_MODE_G and WIRELESS_MODE_B.
I have not tested the code, so you am not sure whether it is the
correct solution.

 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index 33da3df..d4bd550 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -101,7 +101,7 @@ static bool halbtc_legacy(struct rtl_priv *adapter)
 
 	bool is_legacy = false;
 
-	if ((mac->mode == WIRELESS_MODE_B) || (mac->mode == WIRELESS_MODE_B))
+	if ((mac->mode == WIRELESS_MODE_B) || (mac->mode == WIRELESS_MODE_G))
 		is_legacy = true;
 
 	return is_legacy;
-- 
1.9.1
