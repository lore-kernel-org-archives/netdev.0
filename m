From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] hostap: do not return positive number on failure path in prism2_open()
Date: Mon,  5 Aug 2013 07:18:28 +0400
Message-ID: <1375672708-3017-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

prism2_open() as an .ndo_open handler should not return positive numbers
in case of failure, but it does return 1 in a couple of places.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/hostap/hostap_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 15f0fad..e4f56ad 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -667,7 +667,7 @@ static int prism2_open(struct net_device *dev)
 	if (local->no_pri) {
 		printk(KERN_DEBUG "%s: could not set interface UP - no PRI "
 		       "f/w\n", dev->name);
-		return 1;
+		return -ENODEV;
 	}
 
 	if ((local->func->card_present && !local->func->card_present(local)) ||
@@ -682,7 +682,7 @@ static int prism2_open(struct net_device *dev)
 		printk(KERN_WARNING "%s: could not enable MAC port\n",
 		       dev->name);
 		prism2_close(dev);
-		return 1;
+		return -ENODEV;
 	}
 	if (!local->dev_enabled)
 		prism2_callback(local, PRISM2_CALLBACK_ENABLE);
-- 
1.8.1.2
