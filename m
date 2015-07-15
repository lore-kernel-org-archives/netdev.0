From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: "ss -p" segfaults
Date: Wed, 15 Jul 2015 18:52:49 +0000
Message-ID: <C873AEFC-4840-4651-8AE3-F9D21DDDD0DA@intel.com>
References: <2282663.K45lFmE7Zp@fb07-iapwap2>
 <20150715151204.GB28525@angus-think.wlc.globallogic.com>
 <E7D9D05A-8C76-43A4-AF2F-B64C27E6C20B@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_ECACBDFE-DC8A-4447-826B-860A31643412";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Marc Dietrich <marvin24@gmx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:31538 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327AbbGOSxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 14:53:12 -0400
In-Reply-To: <E7D9D05A-8C76-43A4-AF2F-B64C27E6C20B@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_ECACBDFE-DC8A-4447-826B-860A31643412
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Jul 15, 2015, at 9:49 AM, Rustad, Mark D <mark.d.rustad@intel.com> =
wrote:
>=20
>> On Jul 15, 2015, at 8:12 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
>> Would you please check this fix ?
>>=20
>> diff --git a/misc/ss.c b/misc/ss.c
>> index 03f92fa..3a826e4 100644
>> --- a/misc/ss.c
>> +++ b/misc/ss.c
>> @@ -683,8 +683,8 @@ static inline void sock_addr_set_str(inet_prefix =
*prefix, char **ptr)
>>=20
>> static inline char *sock_addr_get_str(const inet_prefix *prefix)
>> {
>> -    char *tmp ;
>> -    memcpy(&tmp, prefix->data, sizeof(char *));
>> +    char *tmp;
>> +    memcpy(&tmp, &prefix->data[0], sizeof(char *));
>>    return tmp;
>> }
>=20
> That surely is not a fix! The destination of the memcpy is the address =
of an uninitialized stack variable! Both versions are equally bad.

I probably over-reacted, but using memcpy to access a pointer in this =
way is just ugly. For one thing, it circumvents any sanity-checking that =
the compiler can do. And changing the prefix->data to &prefix->data[0] =
should be exactly the same thing and therefore should not fix anything. =
Anyway, never mind that.

Looking at more of the code, it looks to me like the the string pointer =
in data can sometimes point to a literal string instead of allocated =
memory when proc is in use. Free would not be happy with that. Look at =
the use of variable peer in function unix_stats_print.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_ECACBDFE-DC8A-4447-826B-860A31643412
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVpqwAAAoJEDwO/+eO4+5uW+gP/i7YN5tqE8aDfs4vblX4+smf
0WPWVVF5fCVQRQNraXexqdqdFoERpb07XXKfWyn7y/kY5SKIhXVw0K+ahkBY6KQU
53txu/vgd3pwZRZIS8ymQLZ0fKy/jgUC74TDtYsouelf+IX5AjLhsDmVtmzmhZuc
1BbgHDV20eP3qxQtdzhbzK5JQxsWnPcuX4IdZfbLRWiqQzma8T4XXG6k70fipWl/
3cZxQCQL3GtvmduarNoX4mzOZdR8xyKm4EFvONCWo1L+DywideHkKCQEXOGItlmS
IXD9+l8U8geNJG+DsaltlvdEO1gA9S+z785RElaCHRGB+ojtoP0TT5LWTmNo5cc3
TZKFr07Q+x2EhwirmL3qd1W3tM+83hJZuMj0kTWRSV3baQdIDUFO8GfXeboAeLcM
jp2gxHY8kC2+ARqbMI3sqtMUNEki2Tl02irLWnw0bY9lYSco4OPU34g050d+FQJn
RX0f8m0mHv9ahsWtnnklDM4vzIy4inCFvjE6aIc8Z1MXadSYHI1q2Ldk9TzbW8vo
9rFS2ncdzG6E3CFX3dufNtGrWeXWJxWWgQxrrpBa43ra3yY2MSSGezhdVrzAMhkJ
JOfySI0YV7+F00NN1nn3xtgVWYt+9ULq2QlJampuj5LKGT/aJKObxml70tyrQmK0
eI1vvX45XNHfHov/E1IE
=pi9k
-----END PGP SIGNATURE-----

--Apple-Mail=_ECACBDFE-DC8A-4447-826B-860A31643412--
