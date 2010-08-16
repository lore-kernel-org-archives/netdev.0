From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 10/16] drivers/net/wireless/wl12xx: Use available error codes
Date: Mon, 16 Aug 2010 18:27:30 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008161827140.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Luciano Coelho <luciano.coelho@nokia.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-ja
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Error codes are stored in ret, but the return value is always 0.  Return
ret instead.

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

 drivers/net/wireless/wl12xx/wl1271_acx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/wl12xx/wl1271_acx.c b/drivers/net/wireless/wl12xx/wl1271_acx.c
index bb245f0..f03ad08 100644
--- a/drivers/net/wireless/wl12xx/wl1271_acx.c
+++ b/drivers/net/wireless/wl12xx/wl1271_acx.c
@@ -269,7 +269,7 @@ int wl1271_acx_pd_threshold(struct wl1271 *wl)
 
 out:
 	kfree(pd);
-	return 0;
+	return ret;
 }
 
 int wl1271_acx_slot(struct wl1271 *wl, enum acx_slot_type slot_time)
