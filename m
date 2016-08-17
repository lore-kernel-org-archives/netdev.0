From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH v2 1/2] kaweth: fix firmware download
Date: Wed, 17 Aug 2016 15:51:55 +0200
Message-ID: <1471441916-19656-2-git-send-email-oneukum@suse.com>
References: <1471441916-19656-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471441916-19656-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes the oops discovered by the Umap2 project and Alan Stern.
The intf member needs to be set before the firmware is downloaded.

Signed-off-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/usb/kaweth.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 770212b..37bf715 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1029,6 +1029,7 @@ static int kaweth_probe(
 	kaweth = netdev_priv(netdev);
 	kaweth->dev = udev;
 	kaweth->net = netdev;
+	kaweth->intf = intf;
 
 	spin_lock_init(&kaweth->device_lock);
 	init_waitqueue_head(&kaweth->term_wait);
@@ -1139,8 +1140,6 @@ err_fw:
 
 	dev_dbg(dev, "Initializing net device.\n");
 
-	kaweth->intf = intf;
