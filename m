From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V3 for 3.19]  rtlwifi: Fix error when accessing unmapped
 memory in skb
Date: Mon, 12 Jan 2015 02:12:23 +0000
Message-ID: <1421028743.19708.44.camel@decadent.org.uk>
References: <1419996787-17395-1-git-send-email-Larry.Finger@lwfinger.net>
	 <20141231050735.GA20639@zzz> <54A4665A.8090906@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FW9pGIs1+k9b/6UhnRV7"
Cc: Eric Biggers <ebiggers3@gmail.com>, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54A4665A.8090906@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FW9pGIs1+k9b/6UhnRV7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-12-31 at 15:10 -0600, Larry Finger wrote:
> On 12/30/2014 11:07 PM, Eric Biggers wrote:
> > On Tue, Dec 30, 2014 at 09:33:07PM -0600, Larry Finger wrote:
> >> v3 - Unmap skb before trying to allocate a new one so as to not leak m=
apping.
> >
> > Looks good to me, although I'm not sure about the handling of DMA mappi=
ng errors
> > (perhaps that's something that drivers typically don't even try to hand=
le?).
> > Anyway, the skb allocation issue appears to be resolved now.  I am runn=
ing your
> > patch with an extra hack to inject some occasional skb allocation failu=
res, and
> > I haven't noticed any problems except dropped packets.
>=20
> The last time I saw any DMA mapping errors were for some early BCM43xx ca=
rds=20
> that only had 20 bits of DMA addressing space. These Realtek devices have=
 a full=20
> 32 bits of addressing, thus any physical address in the first 4GB of RAM =
will be=20
> OK. I suppose that it might be possible to get a physical address outside=
 this=20
> range for machines with a lot of RAM, but they are unlikely to have wifi =
interfaces.
[...]

Really, you don't think laptops and desktops come with 4GB RAM or more?
Besides that, DMA mapping may involve calling an IOMMU driver that may
fail for some reason.

Drivers need to check for DMA mapping errors, it is not optional.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-FW9pGIs1+k9b/6UhnRV7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVLMtjOe/yOyVhhEJAQqoVxAAx9+0J947zdypTcKNcmKK3dHsKrCe2Hk8
QmIH5eokTtDB7sv/KYFpy+cG+l74bJdX84lOd82E3dOrXhpghBbKHpC04PIz18Ve
RxVXdLHv3CQYzLjqNUrL82Yn5S2Sk7Nl3+4JyVFt3vErwrSE2wFSmqf+J5XB4z9O
TFq/W6XVToceZ45IaKl3+8QEhgoFy3zUVhyNTXI7mxMakh9QwTz55ZuhSVUg4fgX
KdrLVeEXM/en46G6ba3HA+iaxMfu20lGHQvhgLSHDCcLJ2SjAqnELdm3mupkBEb+
gcQSOC01xuaMPSJ6P3rjLnJU7rhZzFwIHmHj1hKm9DotpB+6hNq2SEbFrl8M8MKe
w2Wgt0DSMdG0jqlC8KcKWseo4McL+dRtg2VC2d/FHSHQBkM1ULobGPvuZ1zW3DYU
KCfP0jvlLqIvCf5NiR4Zp/Gm1nmhjHYeI5x2Dpdx5U+jl29607UXZH6cPdQ5uE4w
bQLL3cbnCGbb9bfB29yR8LGy8nQdGAHBIiqjwvUe3yNcWX9YDn1/2ZNLht1kCice
6u8qW93GxN624pY6INAHNFjm0owjyIEOZuZBAvHa852DHCK1FXPHmTFfD28wL39G
2IpYsFFtZ0bLUfxXHR04o0Exc8QkCQ4gmO/0MT/HJSP5dEypbnIlOmjQHmuuipVC
tpa++vyNORs=
=vD59
-----END PGP SIGNATURE-----

--=-FW9pGIs1+k9b/6UhnRV7--
