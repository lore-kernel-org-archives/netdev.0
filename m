From: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 14/30] net: Kill some unneeded allocation return value casts in libertas
Date: Fri, 24 Aug 2007 02:03:50 +0200
Message-ID: <2ac91f5f0eed967cf1709cfbe476b351e536c299.1187912217.git.jesper.juhl@gmail.com>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc() and friends return void*, no need to cast it.

Signed-off-by: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/libertas/debugfs.c |    2 +-
 drivers/net/wireless/libertas/ethtool.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 715cbda..6ade63e 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -1839,7 +1839,7 @@ static ssize_t wlan_debugfs_write(struct file *f, const char __user *buf,
 	char *p2;
 	struct debug_data *d = (struct debug_data *)f->private_data;
 
-	pdata = (char *)kmalloc(cnt, GFP_KERNEL);
+	pdata = kmalloc(cnt, GFP_KERNEL);
 	if (pdata == NULL)
 		return 0;
 
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index 96f1974..7dad493 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -60,8 +60,7 @@ static int libertas_ethtool_get_eeprom(struct net_device *dev,
 
 //      mutex_lock(&priv->mutex);
 
-	adapter->prdeeprom =
-		    (char *)kmalloc(eeprom->len+sizeof(regctrl), GFP_KERNEL);
+	adapter->prdeeprom = kmalloc(eeprom->len+sizeof(regctrl), GFP_KERNEL);
 	if (!adapter->prdeeprom)
 		return -ENOMEM;
 	memcpy(adapter->prdeeprom, &regctrl, sizeof(regctrl));
-- 
1.5.2.2
