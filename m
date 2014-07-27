From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Sun, 27 Jul 2014 01:19:40 +0100
Message-ID: <1406420380.29010.129.camel@deadeye.wl.decadent.org.uk>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>
	   <1406050268-13329-3-git-send-email-_govind@gmx.com>
	  <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>
	  <alpine.LNX.2.03.1407230004150.15542@ws.cisco>
	 <1406055025.7427.7.camel@deadeye.wl.decadent.org.uk>
	 <alpine.LNX.2.03.1407230039010.15542@ws.cisco>
	 <alpine.LNX.2.03.1407261603450.3407@ws.cisco>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6uzXNIKd2+xoUJosxNdD"
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57506 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750967AbaG0ATz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 20:19:55 -0400
In-Reply-To: <alpine.LNX.2.03.1407261603450.3407@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6uzXNIKd2+xoUJosxNdD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-07-26 at 16:19 +0530, Govindarajulu Varadarajan wrote:
> On Wed, 23 Jul 2014, Govindarajulu Varadarajan wrote:
>=20
> > On Tue, 22 Jul 2014, Ben Hutchings wrote:
> >> No, you can't do that either.  Basically you can't change the size or
> >> layout of any of the ethtool structures.
> >
> > Ok. Can you suggest me how I should add rx_copybreak to ethtool?
> >
> > May be add another function, set/get_rxcopybreak(), to ethtool_ops?
> >
> > Thanks
> >
>=20
> Should I drop the idea of ethtool and resubmit just the rx_copybreak chan=
ges?
> (use module parameter to change rx_copybreak value).
>=20
> Or should I try something like this
> 3de0b592394d17b 'ethtool: Support for configurable RSS hash key', Create =
new
> ethtool cmd for changing driver rx_copybreak value.

I think that you will need to add new ethtool operations to get and set
this parameter.  At the same time, please consider whether there are
other parameters for buffer allocation and use that might usefully be
configurable in some drivers, so they can be grouped together.

Some parameters that could be included are:

- Maximum frame size that should be copied to a pre-allocated DMA
  buffer rather than DMA-mapped directly from the skb.

  ibmveth has the module parameter 'tx_copybreak' for this.

- Maximum frame size to be transmitted by PIO rather than DMA, where
  the hardware supports both methods.

  The mlx4_en and sfc drivers have hardcoded values for this (MAX_BF
  and EFX_PIOBUF_SIZE_DEF respectively).

- Size of each RX DMA buffer, which is independent of MTU if
  scatter/gather is enabled.

  benet has the module parameter 'rx_frag_size' for this.

Others on netdev might have some other suggestions for inclusion.  You
could also add some reserved space for further expansion.

You should probably include maximum fields for all these, which the
'get' operation would set to 0 if the parameter isn't applicable to the
device.

Ben.

--=20
Ben Hutchings
73.46% of all statistics are made up.

--=-6uzXNIKd2+xoUJosxNdD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU9RFoOe/yOyVhhEJAQpKPg//aBkmg2UIhi4Orn2xB5nTSx/4Stm//03d
hEuwvdTI7VyguHx0l6hHMwwAV9SAMq0wnzT7naW1S4O2ry2freaa8dVpKahEgWHU
jyF7Oh5awjzI+a2iCfq+u9TGdtQiqMW8JJ7k/pQ7bNagplMT6KBFh/cE5x5aECy9
w32+f3Z8I+CcgY4f9b4G+T6sv6QMVzgFE2dnvElmsQYW51NYEI7tKRPoBF9OUoP2
CguwhivdqCOoWP/UpDY9iY8+TYSSJ5FK9GprXXE0Rdw6EFlVcyvTCAN4tS3ea/gV
R8FE+3i+OTGUr9UU4SpU1vsg6++fZTbW7fsVKCGEB4E0Ki14CSIYjtJ1mQV8V0+4
JBOWTTMyOJTa2oCw2f44qiyrvT4vmjYV6s/xMB2lHgcJv0OXnOrLNk1oGig5UJdJ
3Eek8lxDjZBAX3w0O/VkvP8X92QE3DTw2R4u85gPNlTU8k1JxfVgXr1Ijvztdsce
iBYik73mBOVoDrhqPp6RWjnqtsLVYfRuTqT4iUGLQlx8wkuAEU7CCcS/A7VBVMa4
8MDpQk+yhMp3M6Zo0/inLiGPcv+7W0mRfYqeL+t435rHUtGDDb3eN8VQXTahuGY1
dCZVOYnaIct6ulVU+8gTD3iI2VFt7fFSSsuZSJlyVse+v7MthwFOITkKjglJAqzl
f3TEjnhHOyw=
=LsQV
-----END PGP SIGNATURE-----

--=-6uzXNIKd2+xoUJosxNdD--
