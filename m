From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/3] USB: qmi_wwan: Make forced int 4 whitelist generic
Date: Sun, 20 May 2012 12:50:56 +0200
Message-ID: <877gw7i0rz.fsf@nemi.mork.no>
References: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Bird <ajb@spheresystems.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
	(Andrew Bird's message of "Sun, 20 May 2012 09:28:36 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Bird <ajb@spheresystems.co.uk> writes:

> Change the forced interface 4 whitelist to use the generic shared
> binder instead of the Gobi specific one. Certain ZTE devices
> (K3520-Z & K3765-Z) don't work with the Gobi version, but function
> quite happily with the generic. This has been tested with the followi=
ng
> devices:
> K3520-Z
> K3565-Z
> K3765-Z
> K4505-Z
> It hasn't been tested with the ZTE MF820D, which is the only other
> device that uses this whitelist at present. Although Bjorn doesn't
> expect any problems, any testing with that device would be appreciate=
d.
>
> Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>
> ---
>  drivers/net/usb/qmi_wwan.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index d316503b..62a1a43 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -357,9 +357,9 @@ static const struct driver_info	qmi_wwan_gobi =3D=
 {
> =20
>  /* ZTE suck at making USB descriptors */
>  static const struct driver_info	qmi_wwan_force_int4 =3D {
> -	.description	=3D "Qualcomm Gobi wwan/QMI device",
> +	.description	=3D "Qualcomm WWAN/QMI device",
>  	.flags		=3D FLAG_WWAN,
> -	.bind		=3D qmi_wwan_bind_gobi,
> +	.bind		=3D qmi_wwan_bind_shared,
>  	.unbind		=3D qmi_wwan_unbind_shared,
>  	.manage_power	=3D qmi_wwan_manage_power,
>  	.data		=3D BIT(4), /* interface whitelist bitmap */

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>

This fixes a logical error in the code.  Minidriver constructs with an
interface whitelist should not use qmi_wwan_bind_gobi.  It was made to
prevent binding to the serial interfaces on Gobi devices, and serves no
useful purpose when used with a whitelist.  The change is a no-op for
the ZTE MF820D, but is important for new devices.

Thanks for fixing this.


Bj=C3=B8r
