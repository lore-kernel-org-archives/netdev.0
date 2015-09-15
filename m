From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v2] net: mvneta: fix refilling for Rx DMA buffers
Date: Tue, 15 Sep 2015 22:36:34 +0200
Message-ID: <20150915203634.GI7306@kw.sim.vm.gnt>
References: <1437303653-2236-1-git-send-email-simon.guinot@sequanux.org>
 <20150721.003033.1524284435822402813.davem@davemloft.net>
 <CAA-51jPPDHfE1uT2NuJ53wWTvEgh7DcW0K0-xZgQdjAD2CC04w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6iqOn7HZPWKXx18"
Cc: David Miller <davem@davemloft.net>,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	jason@lakedaemon.net, netdev@vger.kernel.org, vdonnefort@gmail.com,
	stable@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	yoann@sculo.fr, linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Oren Laskin <oren@igneous.io>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAA-51jPPDHfE1uT2NuJ53wWTvEgh7DcW0K0-xZgQdjAD2CC04w@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--d6iqOn7HZPWKXx18
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 14, 2015 at 01:22:12PM -0700, Oren Laskin wrote:
> I had to undo this change on my Amada 370 based board.  It was causing
> corrupt data to make it through on large downloads.  I'm using wget to get
> the same 30MB file many times and the SHA would occasionally be different.
> I tracked it down to this commit.  In it, I would find on the order of a
> few hundred bytes to simply be wrong data.

Hi Oren,

Well, you are right. This patch actually introduces a pretty serious
bug. I still don't understand how I missed that in a first place and
I apologize for the inconvenience.

Anyway, I am about to send a patch fixing the issue. Please, can you
test it ?

Thanks in advance,

Simon

> On Tue, Jul 21, 2015 at 12:30 AM, David Miller <davem@davemloft.net> wrot=
e:
>=20
> > From: Simon Guinot <simon.guinot@sequanux.org>
> > Date: Sun, 19 Jul 2015 13:00:53 +0200
> >
> > > With the actual code, if a memory allocation error happens while
> > > refilling a Rx descriptor, then the original Rx buffer is both passed
> > > to the networking stack (in a SKB) and let in the Rx ring. This leads
> > > to various kernel oops and crashes.
> > >
> > > As a fix, this patch moves Rx descriptor refilling ahead of building
> > > SKB with the associated Rx buffer. In case of a memory allocation
> > > failure, data is dropped and the original DMA buffer is put back into
> > > the Rx ring.
> > >
> > > Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> > > Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP
> > network unit")
> > > Cc: <stable@vger.kernel.org> # v3.8+
> > > Tested-by: Yoann Sculo <yoann@sculo.fr>
> >
> > Applied, thanks.
> >
> > _______________________________________________
> > linux-arm-kernel mailing list
> > linux-arm-kernel@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> >

--d6iqOn7HZPWKXx18
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlX4gVIACgkQgtp0PDeOcDpYywCgogyrlKKKcipaiQiEZv26bVU9
XUYAnRi+4MQEFZo1KxJB26jGelqJxKov
=XInw
-----END PGP SIGNATURE-----

--d6iqOn7HZPWKXx18--
