From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] veth: Fix potential memory leak in veth_newlink
Date: Wed, 27 Apr 2016 18:42:19 +0800
Message-ID: <1461753739-4803-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Free peer netdev when failed to configure peer link or register dev.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 drivers/net/veth.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e6..8bb9fb8 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -472,7 +472,6 @@ err_register_dev:
 	/* nothing to do */
 err_configure_peer:
 	unregister_netdevice(peer);
-	return err;
 
 err_register_peer:
 	free_netdev(peer);
-- 
1.8.3.1
