From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: NOHZ: local_softirq_pending 08
Date: Fri, 23 Oct 2009 15:34:29 +0200
Message-ID: <1256304869.12174.20.camel@johannes.local>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>
	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>
	 <4AE0ECCE.2020407@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-7NtKIoavohHzeLGIUrpI"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	Karsten Keil <isdn@linux-pingi.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4AE0ECCE.2020407@imap.cc>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7NtKIoavohHzeLGIUrpI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-10-23 at 01:37 +0200, Tilman Schmidt wrote:

> --- a/drivers/isdn/i4l/isdn_ppp.c
> +++ b/drivers/isdn/i4l/isdn_ppp.c
> @@ -1174,7 +1174,10 @@ isdn_ppp_push_higher(isdn_net_dev * net_dev, isdn_=
net_local * lp, struct sk_buff
>  #endif /* CONFIG_IPPP_FILTER */
>  	skb->dev =3D dev;
>  	skb_reset_mac_header(skb);
> -	netif_rx(skb);
> +	if (in_interrupt())
> +		netif_rx(skb);
> +	else
> +		netif_rx_ni(skb);

So you've verified that the entire i4l stack can cope with being called
twice on the same CPU, from different contexts?

johannes

--=-7NtKIoavohHzeLGIUrpI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK4bDiAAoJEODzc/N7+Qmar1IQAKGLYK9REsXEg22lyNTnuO/O
LHksLqfsQCGlCrc8mV/TBFudWTtOI8WadqlTRNtRyST2c5X+9hB7CAfaXL59liDn
b8h5D0B9dvFoOSkPtyFC9pW9Nw8QEGNym+wv+q/FJvoA1jyAhsAhCTkR63jUhFCk
Zf9d1xE6DtIVHyir7jYgxysVNcZdEQ25hf+s+OM31aMaafWdz83wJB0LWk7DiSjQ
i2U/bJXsFy67cUjFapr6Pl8ZoGQt8Kjama6+ttN91PqcHxREYyC0Yov+jhYiZ3cF
T0qDKUy7W9Jxnpnfmp5ZQ9TDsml//e0klWPKuWCl9gm3y8resgqJcxhAsjkdPcP1
W/FZ3rUiUqdNYsvLZBT3mJcPWApncvvMsfAqd4ziFcFGkbnxkhqD+PC59jlOvJkB
FhVp0V/m5eUawHWtVGHYyjBXEmtAA/c6AUuXvFRLMWfGdou5KOjtHgjG1bp4Umuo
SwZiNhgzTagTGLw1C7oXhny6zm4kU6dOlcT/DFEjpIsMqG9AiWL8EOkw5TI7FQr+
/exgN7g7myiOLL6coLO91+kX1ajPNDEay32S3SdLXdWkls6qR3qysQC6XALfGtAy
q+yR9nLme1Q6I5Rz56USB42iG44Gyb+gqH2BqKZbiNJ3LqrN6XYIwkKmVvkx/3uh
/jYxJWtRCmAc2HcP7gne
=N3Jb
-----END PGP SIGNATURE-----

--=-7NtKIoavohHzeLGIUrpI--

