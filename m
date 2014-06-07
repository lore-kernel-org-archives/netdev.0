From: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: [PATCH 2/2] rsi_91x_sdio: add error handling into rsi_module_init()
Date: Sat,  7 Jun 2014 07:18:31 +0400
Message-ID: <1402111111-8676-2-git-send-email-khoroshilov@ispras.ru>
References: <1402111111-8676-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Fariya Fatima <fariyaf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1402111111-8676-1-git-send-email-khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix rsi_module_init() to propagate sdio_register_driver() errors.

Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
---
 drivers/net/wireless/rsi/rsi_91x_sdio.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio.c b/drivers/net/wireless/rsi/rsi_91x_sdio.c
index 2e39d38d6a9e..f2991682a66a 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio.c
@@ -822,9 +822,11 @@ static struct sdio_driver rsi_driver = {
  */
 static int rsi_module_init(void)
 {
-	sdio_register_driver(&rsi_driver);
+	int ret;
+
+	ret = sdio_register_driver(&rsi_driver);
 	rsi_dbg(INIT_ZONE, "%s: Registering driver\n", __func__);
-	return 0;
+	return ret;
 }
 
 /**
-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
