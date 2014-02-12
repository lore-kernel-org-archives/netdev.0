From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Wed, 12 Feb 2014 22:52:42 +0000
Message-ID: <1392245562.15615.29.camel@deadeye.wl.decadent.org.uk>
References: <1859471893.20140126115521@eikelenboom.it>
	 <20140127000305.GA14236@electric-eye.fr.zoreil.com>
	 <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	 <84816226.20140206123631@eikelenboom.it>
	 <942972114.20140206140909@eikelenboom.it>
	 <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	 <1434499348.20140211205617@eikelenboom.it>
	 <1392154132.6615.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EmbTK6wluDjoMCIYjqB1"
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Dan Williams <dan.j.williams@intel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392154132.6615.91.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EmbTK6wluDjoMCIYjqB1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-11 at 13:28 -0800, Eric Dumazet wrote:
[...]
> Incoming frames might be taken out of order-3 pages.
>=20
> With regular Ethernet frames, this is 21 frames per order-3 pages.
>=20
> ACTIVE_PFN_MAX_OVERLAP seems too small.
>=20
> Alternative would be to user order-0 only pages if CONFIG_DMA_API_DEBUG
> is set. Not sure if it works if PAGE_SIZE=3D66536 ....

Indeed, you can get a lot of packet buffers into a 64K page...

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f589c9af8cbf..1b9995adfd29 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1924,7 +1924,11 @@ static inline void __skb_queue_purge(struct sk_buf=
f_head *list)
>  		kfree_skb(skb);
>  }
> =20
> +#if defined(CONFIG_DMA_API_DEBUG)
> +#define NETDEV_FRAG_PAGE_MAX_ORDER 0
> +#else
>  #define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
> +#endif
>  #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_OR=
DER)
>  #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
> =20

That may be useful for debugging this particular problem, but please
don't make debugging options change behaviour like this.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-EmbTK6wluDjoMCIYjqB1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvv7Oue/yOyVhhEJAQpPYg//eVX07ZxPLbB2YCGGRLGXfVVNdaHNxK1s
6EU7QxjEm2PI8clWDsY9rl5qJWTAwadXmt00GpcgUXBiPYoLy5zBXqDkzF0fxHnR
H9CmjQ8Hs443zPUQUHas7cdvj4RZGjqXpJ2xddQaeOth/sh9E0Cww3uQEs++lUgQ
2wgU7Gjv4JXA4R9UJOtdI9C6XGY3zXZmfhxsRbWaeu1nsQsheNCn01Q/PrtlbyAq
IMKEnx3+WcQugayWs3BHO1Yny0sOItKo6aBOq5Y4ytnaUWbZk3Yq/IJCfxBF0PMl
NkLoiM2tkjNyxWna5NzlcXEqguwG6nwnxGEVkTbFaF1igmFDHYTuwFC+ZQAexRDO
CaXbDbHnyHwNl7mKK53D5TmFg9d7cIF6j8Qh/Cs/rAzKlglbQs3KLqiIQjOVWUTw
9XLk1XLD9zzrXs4x7hnWHIzxnzwE3SBkbj4QEkveEq3SxpYHmrsfYvnCaHYUCPeI
b8QGks9kOi+2sPnrHMndRo/AA60lARsxwZw2UTFza89Re2kwnFfoozM30juZAGHP
2ZuXR1N/mwLY4+xLz+yeHRXY8LCzJU0SvEjTigN0KtlA53a1Awm9K+V3SBqRqv8Y
hAQmchN9W2pDCx1WqhoQ2mueNeRq3chlsjrWKvTtCL/9S6i0pFAdbDZ/ySWSO9fW
qvD0XOdrIzU=
=fBIt
-----END PGP SIGNATURE-----

--=-EmbTK6wluDjoMCIYjqB1--
