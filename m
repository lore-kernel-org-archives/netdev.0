From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: wan: sbni: fix device usage count
Date: Thu,  3 Sep 2015 11:30:30 +0530
Message-ID: <1441260030-8141-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_get_by_name() will increment the usage count if the matching device
is found. But we were not decrementing the count if we have got the
device and the device is non-active.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/wan/sbni.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 758c4ba..8fef8d8 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -1358,6 +1358,8 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 		if( !slave_dev  ||  !(slave_dev->flags & IFF_UP) ) {
 			netdev_err(dev, "trying to enslave non-active device %s\n",
 				   slave_name);
+			if (slave_dev)
+				dev_put(slave_dev);
 			return  -EPERM;
 		}
 
-- 
1.9.1
