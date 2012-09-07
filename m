From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 1/2] net: qmi_wwan: increase max QMI message size to 4096
Date: Fri,  7 Sep 2012 19:36:06 +0200
Message-ID: <1347039367-12399-2-git-send-email-bjorn@mork.no>
References: <1347039367-12399-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347039367-12399-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

QMI requests exceeding 1500 bytes are possible and
device firmware does not handle fragmented messages
very well.  It is therefore necessary to increase
the maximum message size from the current 512 bytes.

The protocol message size limit is not documented
in any publicly known source, but the out of tree
driver from CodeAurora use 4 kB.  This is therefore
chosen as the new arbitrary default until the real
limit is known.

This should allow any QMI message to be transmitted
without fragmentation, fixing known issues with GPS
assistance data upload.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 328397c..516653f 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -108,7 +108,7 @@ static int qmi_wwan_register_subdriver(struct usbne=
t *dev)
 	atomic_set(&info->pmcount, 0);
=20
 	/* register subdriver */
-	subdriver =3D usb_cdc_wdm_register(info->control, &dev->status->desc,=
 512, &qmi_wwan_cdc_wdm_manage_power);
+	subdriver =3D usb_cdc_wdm_register(info->control, &dev->status->desc,=
 4096, &qmi_wwan_cdc_wdm_manage_power);
 	if (IS_ERR(subdriver)) {
 		dev_err(&info->control->dev, "subdriver registration failed\n");
 		rv =3D PTR_ERR(subdriver);
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
