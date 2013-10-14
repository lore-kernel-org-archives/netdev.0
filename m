From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] yam: remove a no-op in yam_ioctl()
Date: Mon, 14 Oct 2013 15:46:15 +0300
Message-ID: <20131014123726.GA17034@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We overwrite the ->bitrate with the user supplied information on the
next line.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 0721e72..5af1c3e 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -975,7 +975,6 @@ static int yam_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EINVAL;		/* Cannot change this parameter when up */
 		if ((ym = kmalloc(sizeof(struct yamdrv_ioctl_mcs), GFP_KERNEL)) == NULL)
 			return -ENOBUFS;
-		ym->bitrate = 9600;
 		if (copy_from_user(ym, ifr->ifr_data, sizeof(struct yamdrv_ioctl_mcs))) {
 			kfree(ym);
 			return -EFAULT;
