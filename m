From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 12:13:37 +0100
Message-ID: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201202132253.16496.jdelvare@suse.de>
	 <22039.1329171191@death.nxdomain> <201202141122.10705.jdelvare@suse.de>
	 <20120214110604.GI32155@v3-1054>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean Delvare <jdelvare@suse.de>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35430 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759682Ab2BNLNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 06:13:40 -0500
Received: by werb13 with SMTP id b13so4081115wer.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 03:13:39 -0800 (PST)
In-Reply-To: <20120214110604.GI32155@v3-1054>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 12:06 +0100, Steffen Klassert a =C3=
=A9crit :
> On Tue, Feb 14, 2012 at 11:22:10AM +0100, Jean Delvare wrote:
> >=20
> > Well I am still curious why the 3c59x driver has such slow polling =
when=20
> > other drivers I have been testing are able to report almost instant=
ly=20
> > when I remove a network cable. Could it be that other network chips=
=20
> > generate an interrupt on cable removal and the 3com chips do not?
> >=20
>=20
> Yes, at least some of the supported chips do not generate an interrup=
t
> on cable removal, so we have to check for this with a timer.
> --

We could have a 5 sec timer in case device is a slave.

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3=
com/3c59x.c
index 1282f04..e463d10 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
 		ok =3D 1;
 	}
=20
-	if (!netif_carrier_ok(dev))
+	if (dev->flags & IFF_SLAVE || !netif_carrier_ok(dev))
 		next_tick =3D 5*HZ;
=20
 	if (vp->medialock)
