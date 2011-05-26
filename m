From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atm: expose ATM device index in sysfs
Date: Thu, 26 May 2011 19:55:09 +0200
Message-ID: <1306432509.2543.1.camel@edumazet-laptop>
References: <1306432057.3151.10.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>, stable@kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43312 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523Ab1EZRzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 13:55:13 -0400
Received: by wya21 with SMTP id 21so706643wya.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 10:55:12 -0700 (PDT)
In-Reply-To: <1306432057.3151.10.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 mai 2011 =C3=A0 12:47 -0500, Dan Williams a =C3=A9crit :
> It's current exposed only through /proc which besides requiring
> screen-scraping doesn't allow userspace to distinguish between two
> identical ATM adapters with different ATM indexes.  The ATM device in=
dex
> is required when using PPPoATM on a system with multiple ATM adapters=
=2E
>=20
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
>=20
> PS: -> stable too since it's a minimal change with no backwards
> incompatibility and I'd like to rely on this attribute in NetworkMana=
ger
>=20
> diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
> index f7fa67c..e5edbde 100644
> --- a/net/atm/atm_sysfs.c
> +++ b/net/atm/atm_sysfs.c
> @@ -59,6 +59,16 @@ static ssize_t show_atmaddress(struct device *cdev=
,
>  	return pos - buf;
>  }
> =20
> +static ssize_t show_atmindex(struct device *cdev,
> +			     struct device_attribute *attr, char *buf)
> +{
> +	char *pos =3D buf;
> +	struct atm_dev *adev =3D to_atm_dev(cdev);
> +
> +	pos +=3D sprintf(pos, "%d\n", adev->number);
> +	return pos - buf;
> +}
> +

What about :

{
	struct atm_dev *adev =3D to_atm_dev(cdev);

	return sprintf(buf, "%d\n", adev->number);
}




