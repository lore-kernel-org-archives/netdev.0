From: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: provide SYN headers for passive connections
Date: Mon, 4 May 2015 10:58:05 -0400
Message-ID: <20150504145805.GE6113@akamai.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
 <20150501201417.GB6113@akamai.com>
 <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150501202908.GC6113@akamai.com>
 <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
 <1430714086.3711.165.camel@edumazet-glaptop2.roam.corp.google.com>
 <CABrhC0nmsfAyHgJX8zEBDBVfFN=2qXKy7cO0Kbp9R9UCeEYowg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UnaWdueM1EBWVRzC"
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Heffner <johnwheffner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CABrhC0nmsfAyHgJX8zEBDBVfFN=2qXKy7cO0Kbp9R9UCeEYowg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--UnaWdueM1EBWVRzC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 04 May 2015, John Heffner wrote:

> On Mon, May 4, 2015 at 12:34 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
> >
> > From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >
> > This patch allows a server application to get the TCP SYN headers for
> > its passive connections.  This is useful if the server is doing
> > fingerprinting of clients based on SYN packet contents.
> >
> > Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.
> >
> > The first is used on a socket to enable saving the SYN headers
> > for child connections. This can be set before or after the listen()
> > call.
> >
> > The latter is used to retrieve the SYN headers for passive connections,
> > if the parent listener has enabled TCP_SAVE_SYN.
> >
> > TCP_SAVED_SYN is read once, it frees the saved SYN headers.
> >
> > The data returned in TCP_SAVED_SYN are network (IPv4/IPv6) and TCP
> > headers.
> >
> > Original patch was written by Tom Herbert, I changed it to not hold
> > a full skb (and associated dst and conntracking reference).
> >
> > We have used such patch for about 3 years at Google.
>=20
>=20
> Nice idea, seems handy.  But a couple (somewhat related) questions:
>=20
> * Other than convenience, are there reasons not use an existing, more
> general-purpose and portable mechanism like pcap?  (Permissions, I
> guess?)

Eric Dumazet can speak for their reasons, but we had a difficult time
guaranteeing that the data collected by libpcap was avaialble to the
accepting thread when accept() returned without making the accepting
thread wait on that data.  With this implementation, we guarantee that
userspace has access to this data when accept() returns.

> * Are there conditions where, for security purposes, you don't want an
> application to have access to the raw SYNs?

In this implementation, userspace does not have access to the raw SYN,
rather it can request a copy of the TCP and IP headers.

Eric

>=20
> Thanks,
>   -John

--UnaWdueM1EBWVRzC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVR4j9AAoJELbVsDOpoOa9FM0P/iM7lpxcKsECnfgPWWdCw2iy
tUe34lfVl2prvFUWT9JAxUpiMwt21ubrtdvgkIKaqgZjZ2H2bwid0NGVRThuZe3t
sz+sgPsjStl3R0zMwrHPfdenJcE6wGhF2NAYl/lDSJnhxRZgHU5W/jOWBsfS7DfN
EVSAiAMu+EUKM4TfOU6ppCSgFkrOa3iGCF8tYn22HK7797lfekXHg6mxBafYFZQU
VKgWA9Z4Cs5pgLRH/4uVSxV9I386YZJwvT3tW9T1HGyj1uP8zsBAmkfZufy3F8QS
4Wuq+8X/ASNslGLdcIEWnCDDeNWS50As6LTLYMTeBQ4z+3odiE4rP0Yy5KlEgR1O
HjLz+l8x4Jlss+7bGqeCT+t+3JNZ/rO2tMdcE+UrBkU78gMiDWtb7W6XUX6SIvSV
PDwBzRaXfBONTHl5UrfBpBE3AMtylg4Ph9SYhJEl8t0Qp/s9tB8onAlGujL3wQF+
X0bBAvY5eONPe68iwxGiCnKuI12QRFJjg3gBiqRL/YBLKgm3qQgHA3ZdmFy9+9Gy
TYs6tZN+6sjEq0KsaVJTV/cqU2dWsUA4BaRNpddlXSpXx3S7ezXvDJrJ+Nr+GrHg
y/bSCWhFA4yfwz8ZmRyUVa7IRNWzQEbLXcfgH23vrR5VpOBVwbB8CHncpdDrEeXH
gqXkxzxuxWR/kHrzcLfM
=bj/R
-----END PGP SIGNATURE-----

--UnaWdueM1EBWVRzC--
