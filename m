From: Pan Bian <bianpan2016@163.com>
Subject: net: lapbether: fix double free
Date: Sun, 29 Oct 2017 21:57:22 +0800
Message-ID: <1509285442-24312-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function netdev_priv() returns the private data of the device. The
memory to store the private data is allocated in alloc_netdev() and is
released in netdev_free(). Calling kfree() on the return value of
netdev_priv() after netdev_free() results in a double free bug.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/wan/lapbether.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 63f7490..0e3f8ed 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -346,7 +346,6 @@ static int lapbeth_new_device(struct net_device *dev)
 fail:
 	dev_put(dev);
 	free_netdev(ndev);
-	kfree(lapbeth);
 	goto out;
 }
 
-- 
1.9.1
