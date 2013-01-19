From: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: [PATCH] iwlegacy: don't return zero on failure paths in il4965_pci_probe()
Date: Sat, 19 Jan 2013 16:56:34 +0400
Message-ID: <1358600194-20371-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If hardware is not ready, il4965_pci_probe() breaks off initialization,
deallocates all resources, but returns zero.
The patch adds -EIO as return value in this case.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
---
 drivers/net/wireless/iwlegacy/4965-mac.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index c3fbf67..c805108 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6553,6 +6553,7 @@ il4965_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	il4965_prepare_card_hw(il);
 	if (!il->hw_ready) {
 		IL_WARN("Failed, HW not ready\n");
+		err = -EIO;
 		goto out_iounmap;
 	}
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
