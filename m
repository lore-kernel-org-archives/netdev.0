From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH 1/8] ath9k: Determine Firmware on probe
Date: Wed, 2 Jun 2010 14:54:46 -0700
Message-ID: <AANLkTiky9UF-aqeZCFleOFSIVw3vDiYbLUdTkkYEWN2B@mail.gmail.com>
References: <19462.12578.143627.398866@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sujith <Sujith.Manoharan@atheros.com>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <19462.12578.143627.398866@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 2, 2010 at 3:23 AM, Sujith <Sujith.Manoharan@atheros.com> w=
rote:
> Do not assign the FW name to driver_info but determine
> it dynamically on device probe. This facilitates adding new
> firmware.
>
> Signed-off-by: Sujith <Sujith.Manoharan@atheros.com>
> ---
> =C2=A0drivers/net/wireless/ath/ath9k/hif_usb.c | =C2=A0 39 ++++++++++=
++++++++++----------
> =C2=A0drivers/net/wireless/ath/ath9k/hif_usb.h | =C2=A0 =C2=A01 +
> =C2=A02 files changed, 27 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/w=
ireless/ath/ath9k/hif_usb.c
> index 77b3591..7da55eb 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.c
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
> @@ -16,12 +16,9 @@
>
> =C2=A0#include "htc.h"
>
> -#define ATH9K_FW_USB_DEV(devid, fw) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0\
> - =C2=A0 =C2=A0 =C2=A0 { USB_DEVICE(0x0cf3, devid), .driver_info =3D =
(unsigned long) fw }
> -
> =C2=A0static struct usb_device_id ath9k_hif_usb_ids[] =3D {
> - =C2=A0 =C2=A0 =C2=A0 ATH9K_FW_USB_DEV(0x9271, "ar9271.fw"),
> - =C2=A0 =C2=A0 =C2=A0 ATH9K_FW_USB_DEV(0x1006, "ar9271.fw"),
> + =C2=A0 =C2=A0 =C2=A0 { USB_DEVICE(0x0cf3, 0x9271) },
> + =C2=A0 =C2=A0 =C2=A0 { USB_DEVICE(0x0cf3, 0x1006) },
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ },
> =C2=A0};
>
> @@ -790,21 +787,21 @@ static int ath9k_hif_usb_download_fw(struct hif=
_device_usb *hif_dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EIO;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_info(&hif_dev->udev->dev, "ath9k_htc: =
Transferred FW: %s, size: %ld\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"ar9271.fw",=
 (unsigned long) hif_dev->firmware->size);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hif_dev->fw_=
name, (unsigned long) hif_dev->firmware->size);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> -static int ath9k_hif_usb_dev_init(struct hif_device_usb *hif_dev,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const char *fw_name)
> +static int ath9k_hif_usb_dev_init(struct hif_device_usb *hif_dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Request firmware */
> - =C2=A0 =C2=A0 =C2=A0 ret =3D request_firmware(&hif_dev->firmware, f=
w_name, &hif_dev->udev->dev);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D request_firmware(&hif_dev->firmware, h=
if_dev->fw_name,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&hif_dev->udev->dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_err(&hif_d=
ev->udev->dev,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "ath9k_htc: Firmware - %s not found\n", fw_name);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "ath9k_htc: Firmware - %s not found\n", hif_dev->fw_name);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_fw_re=
q;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -820,7 +817,8 @@ static int ath9k_hif_usb_dev_init(struct hif_devi=
ce_usb *hif_dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D ath9k_hif_usb_download_fw(hif_dev)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_err(&hif_d=
ev->udev->dev,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "ath9k_htc: Firmware - %s download failed\n", fw_name);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "ath9k_htc: Firmware - %s download failed\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 hif_dev->fw_name);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_fw_do=
wnload;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -847,7 +845,6 @@ static int ath9k_hif_usb_probe(struct usb_interfa=
ce *interface,
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct usb_device *udev =3D interface_to_u=
sbdev(interface);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hif_device_usb *hif_dev;
> - =C2=A0 =C2=A0 =C2=A0 const char *fw_name =3D (const char *) id->dri=
ver_info;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0hif_dev =3D kzalloc(sizeof(struct hif_devi=
ce_usb), GFP_KERNEL);
> @@ -872,7 +869,23 @@ static int ath9k_hif_usb_probe(struct usb_interf=
ace *interface,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_htc_h=
w_alloc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 ret =3D ath9k_hif_usb_dev_init(hif_dev, fw_nam=
e);
> + =C2=A0 =C2=A0 =C2=A0 /* Find out which firmware to load */
> +
> + =C2=A0 =C2=A0 =C2=A0 switch(hif_dev->device_id) {
> + =C2=A0 =C2=A0 =C2=A0 case 0x9271:
> + =C2=A0 =C2=A0 =C2=A0 case 0x1006:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hif_dev->fw_name =3D=
 "ar9271.fw";
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!hif_dev->fw_name) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&udev->dev=
, "Can't determine firmware !\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_htc_hw_al=
loc;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 ret =3D ath9k_hif_usb_dev_init(hif_dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -EINVA=
L;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_hif_i=
nit_usb;
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.h b/drivers/net/w=
ireless/ath/ath9k/hif_usb.h
> index 0aca49b..b2647e8 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.h
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.h
> @@ -90,6 +90,7 @@ struct hif_device_usb {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct usb_anchor regout_submitted;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct usb_anchor rx_submitted;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *remain_skb;
> + =C2=A0 =C2=A0 =C2=A0 const char *fw_name;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rx_remain_len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rx_pkt_len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rx_transfer_len;

I had done some something similar for ar9170 a while back [1] when
adding AVM FRITZ support to ar9170 and then got complaints from Marcel
on this approach since it requires synching the PCI device IDs in two
places. I frankly don't care how we do this but we should try to at
least stick to one way of doing this.

[1] http://osdir.com/ml/linux-wireless/2009-05/msg01219.html

  Luis
