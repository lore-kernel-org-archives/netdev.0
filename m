From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Thu, 24 Nov 2016 22:25:40 +0100
Message-ID: <20161124212540.GA24796@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >> I'm debugging strange delays during transmit in stmmac driver. They
> >> seem to be present in 4.4 kernel (and older kernels, too). Workload is
> >> burst of udp packets being sent, pause, burst of udp packets, ...
=2E..
> > 4.9-rc6 still has the delays. With the
> >=20
> > #define STMMAC_COAL_TX_TIMER 1000
> > #define STMMAC_TX_MAX_FRAMES 2
> >=20
> > settings, delays go away, and driver still works. (It fails fairly
> > fast in 4.4). Good news. But the question still is: what is going on
> > there?
>=20
> 256 packets looks way too large for being a trigger for aborting the
> TX coalescing timer.
>=20
> Looking more deeply into this, the driver is using non-highres timers
> to implement the TX coalescing.  This simply cannot work.
>=20
> 1 HZ, which is the lowest granularity of non-highres timers in the
> kernel, is variable as well as already too large of a delay for
> effective TX coalescing.
>=20
> I seriously think that the TX coalescing support should be ripped out
> or disabled entirely until it is implemented properly in this
> driver.

Ok, I'd disable coalescing, but could not figure it out till. What is
generic way to do that?

It seems only thing stmmac_tx_timer() does is calling
stmmac_tx_clean(), which reclaims tx_skbuff[] entries. It should be
possible to do that explicitely, without delay, but it stops working
completely if I attempt to do that.

On a side note, stmmac_poll() does stmmac_enable_dma_irq() while
stmmac_dma_interrupt() disables interrupts. But I don't see any
protection between the two, so IMO it could race and we'd end up
without polling or interrupts...

Thanks and best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg3WtQACgkQMOfwapXb+vLHMQCdHPyTLYHIREB5QWAGRLOLOwBC
lrUAnA2YKVOee7bf5Nq9IYbbwBHXevQv
=UrYG
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--
