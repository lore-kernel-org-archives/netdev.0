From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net-next 2/2] cpmac: prevent fatal exception in cpmac_end_xmit
Date: Mon, 1 Jun 2009 18:36:55 +0200
Message-ID: <200906011836.59413.florian@openwrt.org>
References: <200905312259.16127.florian@openwrt.org> <20090601.025818.156394734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3145097.RrZoEa3hmh";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:61960 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbZFARb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 13:31:59 -0400
Received: by mail-ew0-f176.google.com with SMTP id 24so8008721ewy.37
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 10:32:00 -0700 (PDT)
In-Reply-To: <20090601.025818.156394734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3145097.RrZoEa3hmh
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

Le Monday 01 June 2009 11:58:18 David Miller, vous avez =E9crit=A0:
> From: Florian Fainelli <florian@openwrt.org>
> Date: Sun, 31 May 2009 22:59:15 +0200
>
> > From: Stefan Weil <weil@mail.berlios.de>
> >
> > We should not be stopping the subqueues in cpmac_end_xmit
> > but rather test the status of them. Replace the calls to
> > netif_subqueue_stop by __netif_subqueue_stopped. This
> > fixes an unrecoverable exception from happening when
> > running the driver.
> >
> > Signed-off-by: Stefan Weil <weil@mail.berlios.de>
> > Signed-off-by: Florian Fainelli <florian@openwrt.org>
>
> Applied, but this commit message was completely wrong and
> therefore misleading to anyone trying to track down why this
> change was made.
>
> The problem is that netif_subqueue_stopped() takes a SKB
> pointer, whereas we're passing in an integer queue index
> here.
>
> Therefore, merely providing the obvious compile warning that
> was produced by this incorrect argument type would have
> explained everything, and accurately.

You are right I should have given you the right description. Thanks for=20
applying it anyway.
=2D-=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
=2D------------------------------

--nextPart3145097.RrZoEa3hmh
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkokA6cACgkQlyvkmBGtjyaTbACeLVCOsNpxrNCgACewwLsYRSmI
XgAAoIwWG5cff7XOAFXRrMhTdLzbnSFB
=NCVE
-----END PGP SIGNATURE-----

--nextPart3145097.RrZoEa3hmh--
