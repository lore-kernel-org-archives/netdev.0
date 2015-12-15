From: "Duda, Lukasz" <Lukasz.Duda@nordicsemi.no>
Subject: RE: [PATCH bluetooth-next] 6lowpan: fix debugfs interface entry name
Date: Tue, 15 Dec 2015 11:47:27 +0000
Message-ID: <AB80DA35A7B64E4E98291794926897D9011B97549F@MBX03.nvlsi.no>
References: <1450178735-1572-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Alexander Aring <alex.aring@gmail.com>,
	"linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nordicsemi.no ([194.19.86.146]:53945 "EHLO
	ironport02.nordicsemi.no" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964922AbbLOLra convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 06:47:30 -0500
In-Reply-To: <1450178735-1572-1-git-send-email-alex.aring@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

> -----Original Message-----
> From: Alexander Aring [mailto:alex.aring@gmail.com]
> Sent: Tuesday, December 15, 2015 12:26
> To: linux-wpan@vger.kernel.org
> Cc: linux-bluetooth@vger.kernel.org; netdev@vger.kernel.org;
> kernel@pengutronix.de; Duda, Lukasz; Alexander Aring
> Subject: [PATCH bluetooth-next] 6lowpan: fix debugfs interface entry =
name
>=20
> This patches moves the debugfs interface related register after netde=
vice
> register. The function lowpan_dev_debugfs_init will use "dev->name" w=
hich
> can be before register_netdevice a format string.
> The function register_netdevice will evaluate the format string if ne=
cessary
> and replace "dev->name" to the real interface name.
>=20
> Reported-by: Lukasz Duda <lukasz.duda@nordicsemi.no>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  net/6lowpan/core.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c index c7f06f5..f=
af65ba
> 100644
> --- a/net/6lowpan/core.c
> +++ b/net/6lowpan/core.c
> @@ -29,13 +29,13 @@ int lowpan_register_netdevice(struct net_device
> *dev,
>=20
>  	lowpan_priv(dev)->lltype =3D lltype;
>=20
> -	ret =3D lowpan_dev_debugfs_init(dev);
> +	ret =3D register_netdevice(dev);
>  	if (ret < 0)
>  		return ret;
>=20
> -	ret =3D register_netdevice(dev);
> +	ret =3D lowpan_dev_debugfs_init(dev);
>  	if (ret < 0)
> -		lowpan_dev_debugfs_exit(dev);
> +		unregister_netdevice(dev);
>=20
>  	return ret;
>  }
> --
> 2.6.1

Thanks, after this change I do have correct interface name under
/sys/kernel/debug/6lowpan for Bluetooth Low Energy (bt0).

Acked-by: Lukasz Duda <lukasz.duda@nordicsemi.no>

Best regards,
=A3ukasz
