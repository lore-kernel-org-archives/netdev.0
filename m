From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Wed, 7 Dec 2016 21:59:42 +0100
Message-ID: <20161207205942.GB2250@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uZ3hkaAS1mZxFaxD"
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uZ3hkaAS1mZxFaxD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> The driver uses a private lock for synchronization between the xmit
> function and the xmit completion handler, but since the NETIF_F_LLTX flag
> is not set, the xmit function is also called with the xmit_lock held.
>=20
> On the other hand the xmit completion handler first takes the private lock
> and (in case that the tx queue has been stopped) the xmit_lock, leading to
> a reverse locking order and the potential danger of a deadlock.
>=20
> Fix this by removing the private lock completely and synchronizing the xm=
it
> function and completion handler solely by means of the xmit_lock. By doing
> this remove also the now unnecessary double check for a stopped tx queue.
>=20
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Oops, sorry no, that broke the driver after a while:

(So please ignore my tested-by:)

root@wagabuibui:/data/tmp/udpt# ./udp-test raw 10.0.0.6 1234 1000 100
30
Sending 100 packets (1000b each) at an interval of 30ms, expected data
rate:3333333b/s (3373333b/s incl udp overhead)
[   30.948626] socfpga-dwmac ff702000.ethernet eth0: Link is Up -
100Mbps/Full - flow control rx/tx
[   31.076064] Link is Up - 100/Full
[   32.979526] random: crng init done
[  262.244030] ------------[ cut here ]------------
[  262.248669] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316
dev_watchdog+0x254/0x26c
[  262.256916] NETDEV WATCHDOG: eth0 (socfpga-dwmac): transmit queue 0
timed out
[  262.264028] Modules linked in:
[  262.267102] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.9.0-rc7-118095-g2d70d9b-dirty #339
[  262.275328] Hardware name: Altera SOCFPGA
[  262.279352] [<8010f758>] (unwind_backtrace) from [<8010affc>]
(show_stack+0x10/0x14)

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--uZ3hkaAS1mZxFaxD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhIeD4ACgkQMOfwapXb+vJQFQCfdgbHFxkINXUIGNQcyxwsEdso
AM4An369JBa0HdeAO+VCgzAGff3oE2zg
=I/rt
-----END PGP SIGNATURE-----

--uZ3hkaAS1mZxFaxD--
