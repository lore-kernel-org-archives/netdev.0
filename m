From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 7/37] drivers/net/wireless/wl12xx: Use kmemdup
Date: Sat, 15 May 2010 23:15:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152314540.21345@ask.diku.dk>
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

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/wl12xx/wl1251_main.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -u -p a/drivers/net/wireless/wl12xx/wl1251_main.c b/drivers/net/wireless/wl12xx/wl1251_main.c
--- a/drivers/net/wireless/wl12xx/wl1251_main.c
+++ b/drivers/net/wireless/wl12xx/wl1251_main.c
@@ -124,7 +124,7 @@ static int wl1251_fetch_nvs(struct wl125
 	}
 
 	wl->nvs_len = fw->size;
-	wl->nvs = kmalloc(wl->nvs_len, GFP_KERNEL);
+	wl->nvs = kmemdup(fw->data, wl->nvs_len, GFP_KERNEL);
 
 	if (!wl->nvs) {
 		wl1251_error("could not allocate memory for the nvs file");
@@ -132,8 +132,6 @@ static int wl1251_fetch_nvs(struct wl125
 		goto out;
 	}
 
-	memcpy(wl->nvs, fw->data, wl->nvs_len);
-
 	ret = 0;
 
 out:
