From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH 3/5] cdc-acm: cleanup error handling
Date: Thu, 14 Jul 2016 15:41:32 +0200
Message-ID: <1468503694-9482-4-git-send-email-oneukum@suse.com>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregKH-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468503694-9482-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A small update to unify error handling during probe().

Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/usb/class/cdc-acm.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/class/cdc-acm.c b/drivers/usb/class/cdc-acm.c
index 70bd642..1857fad 100644
--- a/drivers/usb/class/cdc-acm.c
+++ b/drivers/usb/class/cdc-acm.c
@@ -1328,11 +1328,8 @@ made_compressed_probe:
 		goto alloc_fail;
 
 	minor = acm_alloc_minor(acm);
-	if (minor < 0) {
-		dev_err(&intf->dev, "no more free acm devices\n");
-		kfree(acm);
-		return -ENODEV;
-	}
+	if (minor < 0)
+		goto alloc_fail1;
 
 	ctrlsize = usb_endpoint_maxp(epctrl);
 	readsize = usb_endpoint_maxp(epread) *
@@ -1523,6 +1520,7 @@ alloc_fail4:
 	usb_free_coherent(usb_dev, ctrlsize, acm->ctrl_buffer, acm->ctrl_dma);
 alloc_fail2:
 	acm_release_minor(acm);
+alloc_fail1:
 	kfree(acm);
 alloc_fail:
 	return rv;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
