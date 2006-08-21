From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx-softmac: Init, shutdown and restart fixes
Date: Mon, 21 Aug 2006 16:52:58 +0200
Message-ID: <200608211653.01997.mb@bu3sch.de>
References: <44E9C6A0.3090107@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:25250
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030513AbWHUOxY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 10:53:24 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44E9C6A0.3090107@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 21 August 2006 16:43, Larry Finger wrote:
> Hi John,
>=20
> Please apply this to wireless-2.6.
>=20
> Larry
>=20
> --
>=20
> This fixes various bugs in the init and shutdown code
> that would lead to lockups and crashes, and is the softmac
> equivalent of the patches submitted by Michael Buesch for
> bcm43xx-d80211.
> These changes may fix some of the NETDEV WATCHDOG transmit
> timeouts, but they do not fix all of them, at least not in softmac.
>=20
> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D

Next time please inline the patch.

> @@ -3537,11 +3536,10 @@ static int bcm43xx_init_board(struct bcm
> =A0=A0=A0=A0=A0=A0=A0=A0err =3D bcm43xx_select_wireless_core(bcm, -1)=
;
> =A0=A0=A0=A0=A0=A0=A0=A0if (err)
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto err_crystal_off;
> -
> -=A0=A0=A0=A0=A0=A0=A0bcm43xx_periodic_tasks_setup(bcm);
> =A0=A0=A0=A0=A0=A0=A0=A0err =3D bcm43xx_sysfs_register(bcm);
> =A0=A0=A0=A0=A0=A0=A0=A0if (err)
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto err_wlshutdown;
> +=A0=A0=A0=A0=A0=A0=A0bcm43xx_periodic_tasks_setup(bcm);
> =A0=A0=A0=A0=A0=A0=A0=A0err =3D bcm43xx_rng_init(bcm);
> =A0=A0=A0=A0=A0=A0=A0=A0if (err)
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto err_sysfs_unreg;

Either move bcm43xx_periodic_tasks_setup after rng_init, or
delete the periodic work again, if rng_init fails.


--=20
Greetings Michael.
