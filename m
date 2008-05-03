From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 16:25:20 +0200
Message-ID: <1209824720.1475.6.camel@johannes.berg>
References: <1209639500.7067.0.camel@johannes.berg>
	 <20080501110341.GD7490@gondor.apana.org.au>
	 <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
	 <1209807477.3987.9.camel@johannes.berg>
	 (sfid-20080503_113754_273925_A55099EA)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-11Ive5RmNQe028WNXGGp"
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33716 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294AbYECOZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 10:25:38 -0400
In-Reply-To: <1209807477.3987.9.camel@johannes.berg> (sfid-20080503_113754_273925_A55099EA)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-11Ive5RmNQe028WNXGGp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> One of the worst devices is the Broadcom one with 82 header and nowadays
> actually DMAs this header from a separate memory location, so there this
> won't happen, but can we guarantee that all devices are programmable
> that way? We've seen lots of rather strange devices unfortunately...

The worst case is probably prism54 usb devices which by itself need 76
bytes headroom for the USB buffer, and then when we say run mesh on top
of it we'll need a total of 122 bytes. Needless to say, it cannot do s/g
operation.

The question is: how do we handle that? Do we reallocate the buffer in
the driver? That is well possible but makes it rather inconvenient for
driver authors. Also, mac80211 will still need 46 bytes of headroom and
12 bytes of tailroom in the worst case (so far, HT might require four
more.) If we skb_orphan() the skb right away we have essentially removed
all socket memory accounting, so that's pretty pointless.

Should we increase the LL_MAX_HEADER constant to 40 (no mesh networking)
or 46 for when 802.11 (with mesh networking) is configured into the
kernel? Most people probably don't run an IPIP tunnel over wireless yet
configure them in (especially distros) so that might be why we never saw
the problem before.

johannes

--=-11Ive5RmNQe028WNXGGp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBx1zqVg1VMiehFYAQIIQBAApesfhz/xvWrvVyoWzW1b5XEgahdtBolr
fd53DgW6u4hkAiCvveNWgOUgEBL0/g7ryhfDTc0Lkgdp51o8tNHwXpv7tcQHERJN
dpYvS/Q5eOXxxPfVqHUJEXQLCpjLJO6yYv2I+mhVHpheyvqknCKl90LAGID+kXAd
tGq5ZbH1AT7LLFdVtboFSY+tpYR86A2qwzP+6p19fPQ+MbvhkGy8cXZrumWNtxNE
ZyrMF64OhV7zphrt973SJV2h7htzfIJcJ9mpChE5hMvPFaqtuejL1ep6h+K49Ka5
462Dcvd+38A2XwtHgeSfd2H8J/6XtI8yO5b8TRGsrtyLl6FK+5atMzbevHknZdvL
ki9a6kqhcDdA8uomwXPfo03uI+XUU7uqybmPwVX8fYO4MD+Xz/a+cOf13ZdsVqY+
ILF73gE6ZTyM3NplgL/dayEhIfemwdimV8zYcE4o/hnIjQ1EClP7M1oMOmVyo4TK
jfcvH9DtiL5aKcwEis3gLJVX1CjRo5yVfBQ3qEIUSqy6sNcSnhN6IpDvg17AR60H
wSuo4qDziQjOjoYnCTEQlEGCoge5ClCQCHFiae3O6hF8vn9lTQ1HmBhOSCjTJ60y
GfC9Zj5NvxQmxmnGkaOM/yaoUCSgrCyKQRe/5284+jlhAI2zz8AKo7JXeqaI+RJg
TmQKgM7tG28=
=SIjw
-----END PGP SIGNATURE-----

--=-11Ive5RmNQe028WNXGGp--

