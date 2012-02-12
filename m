From: Paul Menzel <pm.debian@googlemail.com>
Subject: Re: Bug#656331: RTL8168b/8111b with ASUS M2A-VM (SB600): Network
 device stays down after resume
Date: Mon, 13 Feb 2012 00:12:47 +0100
Message-ID: <1329088367.3359.71.camel@mattotaupa>
References: <1326896138.29125.86.camel@mattotaupa>
	 <1326899011.3271.3.camel@deadeye> <1326900763.29125.117.camel@mattotaupa>
	 <1326901834.3271.8.camel@deadeye> <1328383563.20142.23.camel@mattotaupa>
	 <20120205175730.GA23604@electric-eye.fr.zoreil.com>
	 <1328714917.3483.21.camel@mattotaupa> <1328730429.3483.35.camel@mattotaupa>
	 <20120208221644.GA25538@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-WvVZhG8+nDbm15LWcxNz"
Cc: nic_swsd@realtek.com, 656331@bugs.debian.org,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40308 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755897Ab2BLXMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 18:12:53 -0500
Received: by bkcjm19 with SMTP id jm19so4091819bkc.19
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 15:12:51 -0800 (PST)
In-Reply-To: <20120208221644.GA25538@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WvVZhG8+nDbm15LWcxNz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Am Mittwoch, den 08.02.2012, 23:16 +0100 schrieb Francois Romieu:
> Paul Menzel <pm.debian@googlemail.com> :

[=E2=80=A6]

> >         [18764.958557] r8169 0000:02:00.0: PME# disabled
> >         [18781.998004] r8169 0000:02:00.0: eth0: link down
>                      ^^
> >         [18781.998024] r8169 0000:02:00.0: eth0: link down
>                      ^^
> Two link events within 20 us. /me wonders...

        [20195.408746] r8169 0000:02:00.0: PME# enabled
        [20195.466159] r8169 0000:02:00.0: restoring config space at offset=
 0xf (was 0x100, writing 0x10a)
        [20195.466175] r8169 0000:02:00.0: restoring config space at offset=
 0x6 (was 0x4, writing 0xfdaff004)
        [20195.466182] r8169 0000:02:00.0: restoring config space at offset=
 0x4 (was 0x1, writing 0xdc01)
        [20195.466187] r8169 0000:02:00.0: restoring config space at offset=
 0x3 (was 0x0, writing 0x8)
        [20195.466194] r8169 0000:02:00.0: restoring config space at offset=
 0x1 (was 0x100000, writing 0x100407)
        [20195.466826] r8169 0000:02:00.0: PME# disabled
        [20211.376483] r8169 0000:02:00.0: eth0: link down
        [20211.376507] r8169 0000:02:00.0: eth0: link down
       =20
Only ten 24 us difference. But during this resume process the network
came back up fine. Also in my prior pasted output this is also shown at
the beginning but the network worked fine.
       =20
        [20213.000840] r8169 0000:02:00.0: eth0: link up
        [32598.618289] r8169 0000:02:00.0: eth0: link down

This event during resume sometimes shows up and sometimes it does not. I
could not find a correlation between successful and failed resumes.

        [32599.249802] r8169 0000:02:00.0: PME# enabled
        [32599.397941] r8169 0000:02:00.0: restoring config space at offset=
 0xf (was 0x100, writing 0x10a)
        [32599.397956] r8169 0000:02:00.0: restoring config space at offset=
 0x6 (was 0x4, writing 0xfdaff004)
        [32599.397963] r8169 0000:02:00.0: restoring config space at offset=
 0x4 (was 0x1, writing 0xdc01)
        [32599.397968] r8169 0000:02:00.0: restoring config space at offset=
 0x3 (was 0x0, writing 0x8)
        [32599.397975] r8169 0000:02:00.0: restoring config space at offset=
 0x1 (was 0x100000, writing 0x100407)
        [32599.398766] r8169 0000:02:00.0: PME# disabled
        [32599.416148] r8169 0000:02:00.0: eth0: link down

Here it did not work and the link did not come back up. There is over half =
a second time bet

        [32673.504101] r8169 0000:02:00.0: PCI INT A disabled

The module is removed and loaded below.

        [32676.218019] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
        [32676.218078] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low)=
 -> IRQ 19
        [32676.218152] r8169 0000:02:00.0: setting latency timer to 64
        [32676.218246] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
        [32676.219792] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc9=
0000368000, 00:1e:8c:aa:1d:b5, XID 18000000 IRQ 41
        [32676.219803] r8169 0000:02:00.0: eth0: jumbo features [frames: 40=
80 bytes, tx checksumming: ko]
        [32676.563203] r8169 0000:02:00.0: eth0: link down
        [32678.356237] r8169 0000:02:00.0: eth0: link up

> The datasheet states "[the PHYStatus] register is updated continuously at
> maximum periods of 300us." but it is far from clear that the coherency
> with the interrupt status register can be taken for granted. Hayes ?
>=20
> Paul, can you try the hack below ?
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/=
realtek/r8169.c
> index 7a0c800..6daca05 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1278,6 +1278,7 @@ static void __rtl8169_check_link_status(struct net_=
device *dev,
>  {
>  	unsigned long flags;
> =20
> +	udelay(500);
>  	spin_lock_irqsave(&tp->lock, flags);
>  	if (tp->link_ok(ioaddr)) {
>  		rtl_link_chg_patch(tp);

I will try this hack next week. Thank you!

Could it be that there is something wrong with the locking though or
parallel execution? Sometimes

        [32598.618289] r8169 0000:02:00.0: eth0: link down

is shown before=20

        [32599.249802] r8169 0000:02:00.0: PME# enabled

and sometimes it is not or only afterward.


Thanks,

Paul

--=-WvVZhG8+nDbm15LWcxNz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAk84R3AACgkQPX1aK2wOHVhO8wCeIb8wUhXiIK4M2uKE/6BzIumf
QC8AniQ9HoL+N2vjwpKco2Ru1JRBV2C/
=Ke9u
-----END PGP SIGNATURE-----

--=-WvVZhG8+nDbm15LWcxNz--
