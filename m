From: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net:wireless:Add proper locking for the function,
 b43_op_beacon_set_tim in main.c
Date: Sun, 25 Jan 2015 02:06:14 -0500
Message-ID: <1422169574-8451-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Adds proper locking for the function, b43_op_beacon_set_tim in main.c that internally calls b43_update_templates.
Due to the function that is being called internally,b43_update_templates needing the mutex lock of the structure
pointer wl passed  it to run successfully and without issues we add the calls to mutex_lock before and mutex_unlock
after it's call internally in b43_op_beacon_set_tim in order to allow the function,,b43_update_templates to run
successfully and without issues related to concurrent access.

Signed-off-by: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/b43/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 47731cb..b807958 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5094,8 +5094,9 @@ static int b43_op_beacon_set_tim(struct ieee80211_hw *hw,
 {
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 
-	/* FIXME: add locking */
+	mutex_lock(&wl->mutex);
 	b43_update_templates(wl);
+	mutex_unlock(&wl->mutex);
 
 	return 0;
 }
-- 
2.1.0
