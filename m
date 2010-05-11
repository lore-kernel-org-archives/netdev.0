From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/5] drivers/net/wireless/hostap: Drop memory allocation cast
Date: Tue, 11 May 2010 20:25:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005112025280.4330@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Drop cast on the result of kmalloc and similar functions.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
type T;
@@

- (T *)
  (\(kmalloc\|kzalloc\|kcalloc\|kmem_cache_alloc\|kmem_cache_zalloc\|
   kmem_cache_alloc_node\|kmalloc_node\|kzalloc_node\)(...))
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/hostap/hostap_80211_rx.c |    3 +--
 drivers/net/wireless/hostap/hostap_ioctl.c    |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index f4c5612..e0b3e8d 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -355,8 +355,7 @@ static struct hostap_bss_info *__hostap_add_bss(local_info_t *local, u8 *bssid,
 		list_del(&bss->list);
 		local->num_bss_info--;
 	} else {
-		bss = (struct hostap_bss_info *)
-			kmalloc(sizeof(*bss), GFP_ATOMIC);
+		bss = kmalloc(sizeof(*bss), GFP_ATOMIC);
 		if (bss == NULL)
 			return NULL;
 	}
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 9a08230..a85e43a 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -3039,8 +3039,7 @@ static int prism2_ioctl_priv_download(local_info_t *local, struct iw_point *p)
 	    p->length > 1024 || !p->pointer)
 		return -EINVAL;
 
-	param = (struct prism2_download_param *)
-		kmalloc(p->length, GFP_KERNEL);
+	param = kmalloc(p->length, GFP_KERNEL);
 	if (param == NULL)
 		return -ENOMEM;
 
