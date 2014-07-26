From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] isdn/bas_gigaset: fix a leak on failure path in gigaset_probe()
Date: Sat, 26 Jul 2014 12:23:06 +0200
Message-ID: <53D3818A.1060401@imap.cc>
References: <1406327671-28271-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Hansjoerg Lipp <hjlipp@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406327671-28271-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 26.07.2014 00:34, schrieb Alexey Khoroshilov:
> There is a lack of usb_put_dev(udev) on failure path in gigaset_probe=
().

You're right. Good catch.

> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Acked-by: Tilman Schmidt <tilman@imap.cc>

> ---
>  drivers/isdn/gigaset/bas-gigaset.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigase=
t/bas-gigaset.c
> index c44950d3eb7b..b7ae0a0dd5b6 100644
> --- a/drivers/isdn/gigaset/bas-gigaset.c
> +++ b/drivers/isdn/gigaset/bas-gigaset.c
> @@ -2400,6 +2400,7 @@ allocerr:
>  error:
>  	freeurbs(cs);
>  	usb_set_intfdata(interface, NULL);
> +	usb_put_dev(udev);
>  	gigaset_freecs(cs);
>  	return rc;
>  }
>=20

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
