From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: usb: ch9200: use kmemdup instead of kmalloc + memcpy
Date: Wed, 25 Nov 2015 17:19:12 +0100
Message-ID: <87mvu2vypr.fsf@nemi.mork.no>
References: <1448446041-15663-1-git-send-email-anuplimbu14@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mjg59@srcf.ucam.org, tklauser@distanz.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Anup Limbu <anuplimbu14@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448446041-15663-1-git-send-email-anuplimbu14@gmail.com> (Anup
	Limbu's message of "Wed, 25 Nov 2015 15:37:21 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anup Limbu <anuplimbu14@gmail.com> writes:

> replace kmalloc + memset with kmemdup
>
> Signed-off-by: Anup Limbu <anuplimbu14@gmail.com>
> ---
>  drivers/net/usb/ch9200.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/ch9200.c b/drivers/net/usb/ch9200.c
> index 5e151e6..8a40202 100644
> --- a/drivers/net/usb/ch9200.c
> +++ b/drivers/net/usb/ch9200.c
> @@ -155,12 +155,11 @@ static int control_write(struct usbnet *dev, un=
signed char request,
>  		   index, size);
> =20
>  	if (data) {
> -		buf =3D kmalloc(size, GFP_KERNEL);
> +		buf =3D kmemdup(data, size, GFP_KERNEL);
>  		if (!buf) {
>  			err =3D -ENOMEM;
>  			goto err_out;
>  		}
> -		memcpy(buf, data, size);
>  	}
> =20
>  	err =3D usb_control_msg(dev->udev,


Would it be better to replace control_read() and control_write() with
the usbnet_read_cmd() and usbnet_write_cmd() if you are going to clean
this up?



Bj=C3=B8rn
