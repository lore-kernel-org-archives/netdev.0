From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: Checksum offload queries
Date: Thu, 10 Dec 2015 21:02:18 +0000
Message-ID: <75AC3A2B-FC0A-4151-BD53-3013970E6609@intel.com>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
 <56681B18.3030200@solarflare.com>
 <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
 <566864C0.6020204@solarflare.com>
 <CALx6S34+j0xQk7gfwOa9adBc3fkjhTJG366eDcT81AzKnWCrLA@mail.gmail.com>
 <56699F15.3030202@solarflare.com>
 <CALx6S34bg-iRMcTpGd+yw+CV1T7MxpWx+i_AdxXjsfTTnOGK4g@mail.gmail.com>
 <5669E066.8090703@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_9862BD6A-A3ED-4120-97FF-A3DB2CB69ADD";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:15364 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbbLJVC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 16:02:27 -0500
In-Reply-To: <5669E066.8090703@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_9862BD6A-A3ED-4120-97FF-A3DB2CB69ADD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Edward Cree <ecree@solarflare.com> wrote:

> I have just realised something startling.  Assuming the inner protocol =
uses the ones complement checksum in the way IP, UDP and TCP do, the =
outer checksum can be computed *without looking at the payload*.  Why?  =
Because the ones complement sum of (say) a correctly checksummed UDP =
datagram is simply the complement of the ones complement sum of the =
pseudo header.  Similarly, the ones complement sum of a correctly =
checksummed IP header is zero.
> Therefore, the outer checksum depends _only_ on the inner and outer =
pseudo headers and the encapsulation headers.  For example, with UDP =
encapsulated in VXLAN, we have the following packet structure:
> ETH IP UDP VXLAN inner-ETH inner-IP inner-UDP PAYLOAD
> and the outer checksum equals
> ~([outer_pseudo] + [UDP] + [VXLAN] + [inner-ETH] + ~[inner_pseudo])
> where [] denotes summation, and all addition is ones complement.
> This can easily be computed in software, especially as the stack =
already has ~[inner_pseudo]: it's stored in the inner checksum field to =
help inner checksum offload.
>=20
> Have I made a mistake in my ones-complement maths, or is outer =
checksum offload as unnecessary as IP header checksum offload?

I agree with the overall observation, in that the outer checksum can be =
derived from the inner one. I think that the inner-ip header needs to be =
added (after subtracting out the inner_pseudo as you indicate above), =
because the entire raw inner IP header needs to be included in the outer =
checksum. I haven't thought this all through in detail yet. It would be =
really nice to have a function that implemented something like this. =
Could one be structured to handle most encapsulations?

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_9862BD6A-A3ED-4120-97FF-A3DB2CB69ADD
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWaehaAAoJEDwO/+eO4+5u9PkQAI60jGQ2f8Me+Tlbv8PpmQxi
zOx2l6DTuuoDP2xmy/36YqGsd3LzBpAU4/5QylWKlrRMFQUhNaCLMlXdFhqQqGCc
Hm2SIL53Mu8OTRRFdpMgNITpayEJrtiWa0SiYgXDmTN3zQEgujYJAWmRq51+7d4D
6AixHd9oWe6IJVPxjybINKwCdap1hQ9Ai9qpUB2vEBAba9bZG/jyBwboceusqNLB
wdaq7WyQRK8GNvnT47UDI9QQ0ZY555UWa0Ek2UV/VMZoseykEDjl1vQYlQeTh1HW
0X5gn0us14n0zBUs7PUP4TxsCpDEOet+9UUGRx/yQeymOpm5MMY8v4O5vn0UfuX7
xfATcyI4lhBGn2qIApBj8J1EtROfIVUU+ohGAyxbNgNWUO6x1wZvApgGwjAmZ6Ha
8pIcX3KgwfwO5VLGJh98deIhsvLL+sNhyLWsW7+bt6MwCjiQNK5WqSWYVd76A5yD
+8uBRlKY6osNrfwVg8amu9APzav3R/z+vEKrL/4a4sGicplekC5swOHEkESn9sZx
0KLXNfGHLW/BggglZAB8NWGR+7xwh3l3kUjBalFncS9m0McyAh+e9be9nuWTBMPE
Ws93PCaNr8BhKH/LvM5vw2DITs0/mqBXSGYxR+Z3pPj5ELz4n0iDaxGULQLw9zFV
09JXdyc+LvfSXZqLbYVv
=mQou
-----END PGP SIGNATURE-----

--Apple-Mail=_9862BD6A-A3ED-4120-97FF-A3DB2CB69ADD--
