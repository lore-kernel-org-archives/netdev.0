From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V3 1/6] net/ethtool: introduce a new ioctl for per queue
 setting
Date: Sun, 17 Jan 2016 02:00:17 +0000
Message-ID: <1452996017.2519.29.camel@decadent.org.uk>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ia8w/WLCLf7/QtjvVqsh"
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53943 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbcAQCAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 21:00:46 -0500
In-Reply-To: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ia8w/WLCLf7/QtjvVqsh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-01-14 at 09:08 -0500, kan.liang@intel.com wrote:
[...]
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1144,6 +1144,21 @@ enum ethtool_sfeatures_retval_bits {
> =C2=A0#define ETHTOOL_F_WISH=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0(1 << ETHTOOL_F_WISH__BIT)
> =C2=A0#define ETHTOOL_F_COMPAT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0(1 << ETHTOOL_F_COMPAT__BIT)
> =C2=A0
> +#define MAX_NUM_QUEUE		4096
> +
> +/**
> + * struct ethtool_per_queue_op - apply sub command to the queues in mask=
.
> + * @cmd: ETHTOOL_PERQUEUE
> + * @sub_command: the sub command which apply to each queues
> + * @queue_mask: Bitmap of the queues which sub command apply to
> + * @data: A complete command structure following for each of the queues =
addressed
> + */
> +struct ethtool_per_queue_op {
> +	__u32	cmd;
> +	__u32	sub_command;
> +	unsigned long queue_mask[BITS_TO_LONGS(MAX_NUM_QUEUE)];
[...]

I thought we already agreed that this won't work for 32-bit userland on
a big-endian 64-bit kernel?

Ben.

--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers
--=-Ia8w/WLCLf7/QtjvVqsh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVpr1see/yOyVhhEJAQqE/BAAqzM4XtMdE2hgNYEkQSiVbfH75DzRjoG9
qqZc9RnV11BtnzaLCatwuuQ7J9hU8zY1NpQ1E6DhwfCwtf/aSIPqRIs1Catn4SkJ
hNrPVhyqbIizEfEp+IJu2rRva73DYVE6M7H96fX227o3gBU79MsTd05G5jVvnvG7
YEDlxa6zcETfB6TNKWje0Ci1TkiFaUgTnMUh3aZBwhN56hblBnzUVu5sg82135pw
SF2lUCTuUe+LPinomA0pOLwifY1bD6QavxkHL4Ym3PeiL/1J45SWNg/0P3hWzZmq
wEXp9iI86fnsbQQ4xeOWTneLO4m1TPqqQ6FGDPy4snAjNZEtin69bv7nGK3uXGtj
LHBBQvLrkrtbupNbcex5888SsBFAP0Auy7XpKGfT5L4FkLCtLrR1zt1qcy6Ahyzk
QL2wq0xj87s6I/AQQLR8ChjU3lrx2oDpoCXKkPFFacJW3iOGgsNxRd2PLB1Awlzv
pYH0Nbwc0rQDDFQZpRLEFSE64G4bwIozeSpiQ+ZuVbQtliHrLfrD2ruj68vgn/rR
/UfS9KiJbaitXwW3L7xtjjuTejS8nfxB8eb5RNv2lCwoU0DJgcVQePprZG/7CD1o
2BVyYo/+pMrxx9Ali7Zyw8sz+LyphusfDDn8xR4gWC2o13ysdulW1+n8Wgmi+FZQ
OCe8ki6ayxU=
=GPua
-----END PGP SIGNATURE-----

--=-Ia8w/WLCLf7/QtjvVqsh--
