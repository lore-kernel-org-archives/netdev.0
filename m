From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Sun, 01 May 2011 16:46:39 +0100
Message-ID: <1304264799.2833.82.camel@localhost>
References: <1304247656-21086-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dgiagio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dborca-/E1597aS9LQAvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pmcenery-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, david.hill-+VOaU5BgciZBDgjK7y7TUQ@public.gmane.org,
	"open list:USB SUBSYSTEM" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "L. Alberto" =?ISO-8859-1?Q?Gim=E9nez?= <agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1304247656-21086-1-git-send-email-agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-05-01 at 13:00 +0200, L. Alberto Gim=C3=A9nez wrote:
> From: David Hill <david.hill-+VOaU5BgciZBDgjK7y7TUQ@public.gmane.org>
>=20
> Since commit ea812ca1b06113597adcd8e70c0f84a413d97544, NET_IP_ALIGN c=
hanged from
> 2 to 0. Some people have reported that tethering stopped working and =
David Hill
> submited a patch that seems to fix the problem.
>=20
> I have no more an iPhone device to test it, so it is only compile-tes=
ted.
>=20
> Signed-off-by: L. Alberto Gim=C3=A9nez <agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>
> ---
>  drivers/net/usb/ipheth.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
> index 7d42f9a..711346b 100644
> --- a/drivers/net/usb/ipheth.c
> +++ b/drivers/net/usb/ipheth.c
> @@ -54,6 +54,9 @@
>  #include <linux/usb.h>
>  #include <linux/workqueue.h>
> =20
> +#undef  NET_IP_ALIGN
> +#define NET_IP_ALIGN 2
> +
>  #define USB_VENDOR_APPLE        0x05ac
>  #define USB_PRODUCT_IPHONE      0x1290
>  #define USB_PRODUCT_IPHONE_3G   0x1292

No, you can't do this.

If there is some reason to use a fixed alignment of 2 (which I find har=
d
to believe; this is a USB device after all) then that should be
specified as a private constant.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
