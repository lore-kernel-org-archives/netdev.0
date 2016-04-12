From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] cdc_mbim: apply "NDP to end" quirk to all Huawei devices
Date: Tue, 12 Apr 2016 16:11:12 +0200
Message-ID: <1460470272-9289-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Fett <andreas.fett-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>,
	Andrei Burd <burdandrei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We now have a positive report of another Huawei device needing
this quirk: The ME906s-158 (12d1:15c1).  This is an m.2 form
factor modem with no obvious relationship to the E3372 (12d1:157d)
we already have a quirk entry for.  This is reason enough to
believe the quirk might be necessary for any number of current
and future Huawei devices.

Applying the quirk to all Huawei devices, since it is crucial
to any device affected by the firmware bug, while the impact
on non-affected devices is negligible.

The quirk can if necessary be disabled per-device by writing
N to /sys/class/net/<iface>/cdc_ncm/ndp_to_end

Reported-by: Andreas Fett <andreas.fett-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
I'm requesting this for stable, but it depends on commit

  f8c0cfa5eca9 ("net: cdc_mbim: add "NDP to end" quirk for Huawei E3372=
")

so it is only applicable to v4.3 (where the dependency is
backported), v4.4 and v4.5


Bj=C3=B8rn

 drivers/net/usb/cdc_mbim.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index bdd83d95ec0a..96a5028621c8 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -617,8 +617,13 @@ static const struct usb_device_id mbim_devs[] =3D =
{
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x0bdb, USB_CLASS_COMM, USB_CDC_SUBCL=
ASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info,
 	},
-	/* Huawei E3372 fails unless NDP comes after the IP packets */
-	{ USB_DEVICE_AND_INTERFACE_INFO(0x12d1, 0x157d, USB_CLASS_COMM, USB_C=
DC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
+
+	/* Some Huawei devices, ME906s-158 (12d1:15c1) and E3372
+	 * (12d1:157d), are known to fail unless the NDP is placed
+	 * after the IP packets.  Applying the quirk to all Huawei
+	 * devices is broader than necessary, but harmless.
+	 */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, USB_CLASS_COMM, USB_CDC_SUBCL=
ASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info_ndp_to_end,
 	},
 	/* default entry */
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
