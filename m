From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] cfg80211: fix signed macaddress in sysfs
Date: Mon, 11 Jun 2007 21:17:16 -0400
Message-ID: <20070612011716.GD20422@tuxdriver.com>
References: <20070612011616.GC20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070612011616.GC20422-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Lamparter <lists-cEeocvCgqOOsTnJN9+BGXg@public.gmane.org>

Fix signedness mixup making mac addresses show up strangely
(like 00:11:22:33:44:ffffffaa) in /sys/class/ieee80211/*/macaddress.

Signed-off-by: David Lamparter <equinox-cEeocvCgqOOsTnJN9+BGXg@public.gmane.org>
Acked-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/wireless/sysfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
index 3ebae14..88aaacd 100644
--- a/net/wireless/sysfs.c
+++ b/net/wireless/sysfs.c
@@ -33,7 +33,7 @@ static ssize_t _show_permaddr(struct device *dev,
 			      struct device_attribute *attr,
 			      char *buf)
 {
-	char *addr = dev_to_rdev(dev)->wiphy.perm_addr;
+	unsigned char *addr = dev_to_rdev(dev)->wiphy.perm_addr;
 
 	return sprintf(buf, "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\n",
 		       addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
