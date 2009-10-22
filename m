From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Thu, 22 Oct 2009 10:27:01 +0200
Message-ID: <1256200021.12174.11.camel@johannes.local>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>
	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>
	 <20091021211906.GA11401@ami.dom.local>
	 <1256160330.12174.2.camel@johannes.local>
	 <20091021213947.GA12202@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-CucNFXYmnSnNQhEM6i4T"
Cc: Tilman Schmidt <tilman@imap.cc>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20091021213947.GA12202@ami.dom.local>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CucNFXYmnSnNQhEM6i4T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-10-21 at 23:39 +0200, Jarek Poplawski wrote:

> > > -	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> > > +	raise_softirq_irqoff(NET_RX_SOFTIRQ);
> >=20
> > This still doesn't make any sense.
> >=20
> > There may or may not be a lot of code that assumes that everything else
> > is run with other tasklets disabled, and that it cannot be interrupted
> > by a tasklet and thus create a race.
> >=20
> > Can you prove that is not the case, across the entire networking layer?
>=20
> I'm not sure I can understand your question. This patch is mainly to
> avoid using netif_rx()/netif_rx_ni() pair as a test of proper process
> context handling; IMHO there're better tools for this (lockdep,
> WARN_ON's).

And how exactly does that matter to the patch at hand?!

I'm saying that it seems to me, as indicated by the API (and without
proof otherwise that's how it is) the networking layer needs to have
packets handed to it with softirqs disabled. Therefore, this patch is
not needed. While it may not be _wrong_, it'll definitely introduce a
performance regression.

This really should be obvious. You're fixing the warning at the source
of the warning, rather than the source of the problem.

johannes

--=-CucNFXYmnSnNQhEM6i4T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK4BdSAAoJEODzc/N7+QmazNcP/1JmQK9nI+Lg9fAQRj+Anj4h
dzuASnI6MGz+uSIueUNPQN7uv57tvD17jsftZzgR2MawI6WDJSNR6qZM2eICXKa6
HUfxBlByQ7mQN+IuigMlop1ZGTHza7UjUVQq/YLsVU99y4LwAPZJIYddAbtiXzWq
xrOPSSc1QUIjfgZct+FlJBrdS/G0JIxCNwyD7HyJcxaSyOuNW/lmqg7YEF6hnoCV
NBVCszM0KUHaxQVumy97YnaIOvxC8w+fVycI4kvWDhKLhHfwowc+Vi3/Pkb5ofML
WaWTvaoEGeml99YD2uprZb5vKWmKGm4NxHJr2s/3AC0xbDVLsXDg9hPVZdTwVE0d
Hx4L4uYQC4hr9+TRrFBDYqymbYgbJ0ZufdrIwicygQBpOZfLDmx7M47LDGlbJ7D3
LfE5PWu3C0+qegi9k5MI8w6DlyVlVAnG6jgWGgyNle5fOCg7cmN+IBGl57XrTVPF
G1vRBDSFzBLDUQPRkBrwDO7rDNRoB3xiOAQiDNsKf1h0zdsDY4PlgOKlT6A6sVMC
8UqB5D1nLM57IShUH+0bypp9GNEN7q2XGge8nyXYKDsMlPZjLOJMMUR5IdJZxnbS
CeIWTQqoqu/inV381OWn4S20tofOQI38F4h4WOWswLUlRbWh+HDPTnfJpeim2Z7q
u6tvV3UkEoicmPfJcqbD
=aeCA
-----END PGP SIGNATURE-----

--=-CucNFXYmnSnNQhEM6i4T--

