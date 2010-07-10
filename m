From: Kulikov Vasiliy <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] adm8211: fix memory leak
Date: Sat, 10 Jul 2010 16:28:57 +0400
Message-ID: <1278764938-9417-1-git-send-email-segooon@gmail.com>
Cc: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We must free priv->eeprom allocated in adm8211_read_eeprom().

Signed-off-by: Kulikov Vasiliy <segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/adm8211.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 880ad9d..bde2fa8 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1903,7 +1903,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR "%s (adm8211): Cannot register device\n",
 		       pci_name(pdev));
-		goto err_free_desc;
+		goto err_free_eeprom;
 	}
 
 	printk(KERN_INFO "%s: hwaddr %pM, Rev 0x%02x\n",
@@ -1912,6 +1912,9 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 
 	return 0;
 
+ err_free_eeprom:
+	kfree(priv->eeprom);
+
  err_free_desc:
 	pci_free_consistent(pdev,
 			    sizeof(struct adm8211_desc) * priv->rx_ring_size +
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
