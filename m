From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next v2 03/11] ixgbe: Use static inlines instead of macros
Date: Fri, 3 Jan 2014 18:31:38 +0000
Message-ID: <F2605A6D-0AC1-4507-9E85-AB89599C36BB@intel.com>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1388726310-2996-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <1388726884.2527.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_98088610-9CAD-4B1B-A4EB-E56BB627CD68";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56606 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbaACScG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 13:32:06 -0500
In-Reply-To: <1388726884.2527.4.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_98088610-9CAD-4B1B-A4EB-E56BB627CD68
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

On Jan 2, 2014, at 9:28 PM, Joe Perches <joe@perches.com> wrote:

> On Thu, 2014-01-02 at 21:18 -0800, Jeff Kirsher wrote:
>> From: Mark Rustad <mark.d.rustad@intel.com>
> []
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h =
b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> []
>> @@ -124,22 +124,31 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw =
*hw);
>> #ifndef writeq
>> #define writeq(val, addr) writel((u32) (val), addr); \
>>     writel((u32) (val >> 32), (addr + 4));
>> #endif
>=20
> This is unchanged, but it would be nicer with a do {} while.

Yes, it is definitely a trap for a macro to directly generate two =
statements like this. The #ifdef check seemed a little dubious to me =
when I first saw it, but at the time I chose to stick to what I had to =
do and then forgot to revisit this.

> #ifndef writeq
> #define writeq(val, addr)				\
> do {							\
> 	writel((u32)(val), addr);			\
> 	writel((u32)((val) >> 32), (addr + 4));		\
> } while (0)

Now that I have looked into it, I only fear becoming a "mucking foron" =
by touching it at all! :-) (grep the alpha arch code) Lacking an =
ARCH_HAS macro for detecting writeq, it does appear that this check is =
currently the way to do it, though it probably makes no sense whatsoever =
to compile this driver for any architecture that is not defining writeq. =
I wonder how many of these sequences were added in support of =
randconfig?

> Even then, this could be nicer as an inline too.

It does appear that the other places checking for writeq are being =
implemented with static inlines, so that should be the preferred method =
here as well.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_98088610-9CAD-4B1B-A4EB-E56BB627CD68
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSxwIIAAoJEDwO/+eO4+5usFMP/RRojQsqga33eHnphn5SfGGq
9m06XD9jY1BmkZeu8kJEPLM2dqUSbx3O2tDWvf5VHENUklNBSem2t8uxHEFZ7Xyk
v/WDmYu8I4T4sCQCfhT4m8tAlLrX5qZRGHPP8tZkh+mWmCnHgH1ocZrvWWmZo47C
TfY8kuE4JTyreSLEgRalbI5cu1l/1RkmanbpQZ109B4t5SIuYejsjLRtxuYKremP
7Elhzqi0p8Tc1pMl20gHzGyQanbEL13QzVWVpJDxDNrH6AZmUsLReNMSzWQHsCFB
GJ1vNACZp0k2ulR4EYszmjAQXQ4cjD9834F3RM7781XHpbtjYgbBpIbfLDi3eiP6
M78p5lyElkMrhbOHDPRe9T02/M6NWyYNMSAsRjAb4dlQqNjt0R5/L6fOd4jZaVhk
I9yqI6OZLWqAYBAFe54t+X64W8xU5CQftvPSmZUhaA7D0BPJOO0Wz7CvLMbXcNsb
gscsMocp3aoNk46sz7oBmeS/A09TpQlUyKN6Re9iQFO8hemxV5x3XkhjZFpVNG/h
Yoob5YwPftVUKFZXGauK8XVCqe9ES4MhsXNu/HF/S88oDcRRYOSDHRXBvU9J64Mq
V1cgL4PJHWUqhuqFRrF2jugPBWMP3Z4E7z9zbHdenzS5DFnAxsc5VOR3AA6liBxd
C7uI/21L399FxNcL4T17
=+VHH
-----END PGP SIGNATURE-----

--Apple-Mail=_98088610-9CAD-4B1B-A4EB-E56BB627CD68--
