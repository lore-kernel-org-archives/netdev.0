From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/16] drivers/net/wireless/wl12xx: Use available error codes
Date: Mon, 16 Aug 2010 18:25:21 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008161825010.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Kalle Valo <kalle.valo@iki.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In each case, error codes are stored in ret, but the return value is always
0.  Return ret instead.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
local idexpression x;
constant C;
@@

if (...) { ...
  x = -C
  ... when != x
(
  return <+...x...+>;
|
  return NULL;
|
  return;
|
* return ...;
)
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This changes the semantics and has not been tested.

 drivers/net/wireless/wl12xx/wl1251_acx.c |    2 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/wl1251_acx.c b/drivers/net/wireless/wl12xx/wl1251_acx.c
index 91891f9..2f8a2ba 100644
--- a/drivers/net/wireless/wl12xx/wl1251_acx.c
+++ b/drivers/net/wireless/wl12xx/wl1251_acx.c
@@ -380,7 +380,7 @@ int wl1251_acx_pd_threshold(struct wl1251 *wl)
 
 out:
 	kfree(pd);
-	return 0;
+	return ret;
 }
 
 int wl1251_acx_slot(struct wl1251 *wl, enum acx_slot_type slot_time)
diff --git a/drivers/net/wireless/wl12xx/wl1251_cmd.c b/drivers/net/wireless/wl12xx/wl1251_cmd.c
index a37b30c..949b6a3 100644
--- a/drivers/net/wireless/wl12xx/wl1251_cmd.c
+++ b/drivers/net/wireless/wl12xx/wl1251_cmd.c
@@ -200,7 +200,7 @@ int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 
 out:
 	kfree(vbm);
-	return 0;
+	return ret;
 }
 
 int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
