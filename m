From: Joe Eykholt <jre@nuovasystems.com>
Subject: Re: [patch]  bondig - arp_interval with low value => Oops.
Date: Sat, 17 May 2008 13:20:06 -0700
Message-ID: <482F3DF6.7080403@nuovasystems.com>
References: <482C9E73.2040202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas 2P <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:5949 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755756AbYEQUUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 16:20:11 -0400
In-Reply-To: <482C9E73.2040202@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas 2P wrote:
> When setting arp_interval parameter to a very low value, delta_in_tic=
ks=20
> for next arp might become 0, causing an infinite loop.
>=20
> See http://bugzilla.kernel.org/show_bug.cgi?id=3D10680
>=20
> Same problem for miimon parameter already fixed, but fix might be=20
> enhanced, by using msecs_to_jiffies() function.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>=20
> --- /usr/src/linux/drivers/net/bonding/bond_main_orig.c 2008-05-13=20
> 02:00:01.000000000 +0200
> +++ /usr/src/linux/drivers/net/bonding/bond_main.c      2008-05-14=20
> 14:55:53.000000000 +0200
> @@ -2391,7 +2391,7 @@
>                 read_lock(&bond->lock);
>         }
>=20
> -       delay =3D ((bond->params.miimon * HZ) / 1000) ? : 1;
> +       delay =3D msecs_to_jiffies(bond->params.miimon);
>         read_unlock(&bond->lock);
>         queue_delayed_work(bond->wq, &bond->mii_work, delay);
>  }
> @@ -2704,7 +2704,7 @@
>=20
>         read_lock(&bond->lock);
>=20
> -       delta_in_ticks =3D (bond->params.arp_interval * HZ) / 1000;
> +       delta_in_ticks =3D msecs_to_jiffies(bond->params.arp_interval=
);
>=20
>         if (bond->kill_timers) {
>                 goto out;
> @@ -2837,7 +2837,7 @@
>=20
>         read_lock(&bond->lock);
>=20
> -       delta_in_ticks =3D (bond->params.arp_interval * HZ) / 1000;
> +       delta_in_ticks =3D msecs_to_jiffies(bond->params.arp_interval=
 * HZ);

This seems like it should be just:

	delta_in_ticks =3D msecs_to_jiffies(bond->params.arp_interval);

Assuming the interval is in milliseconds, based on the previous usage.
Since it's multiplying by HZ (ticks per second) and dividing by 1000=20
(milliseconds per second), it was converting from milliseconds to ticks=
=2E

Same for the other changes?

	Joe
