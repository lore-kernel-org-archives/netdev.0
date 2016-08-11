From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 12/16] net: wireless: broadcom: brcm80211: brcmfmac: usb: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:31 +0200
Message-ID: <1470949539-25392-13-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949539-25392-1-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
index 98b15a9a2779f4..fa26619a7945d9 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
@@ -1099,15 +1099,11 @@ struct brcmf_usbdev *brcmf_usb_attach(struct brcmf_usbdev_info *devinfo,
 	devinfo->tx_freecount = ntxq;
 
 	devinfo->ctl_urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!devinfo->ctl_urb) {
-		brcmf_err("usb_alloc_urb (ctl) failed\n");
+	if (!devinfo->ctl_urb)
 		goto error;
-	}
 	devinfo->bulk_urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!devinfo->bulk_urb) {
-		brcmf_err("usb_alloc_urb (bulk) failed\n");
+	if (!devinfo->bulk_urb)
 		goto error;
-	}
 
 	return &devinfo->bus_pub;
 
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
