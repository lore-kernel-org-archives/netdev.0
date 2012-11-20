From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Tue, 20 Nov 2012 09:30:21 +0100
Message-ID: <50AB3F9D.4070905@canonical.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com> <1349790863.21172.4406.camel@edumazet-glaptop> <1349792241.21847.199.camel@zakaz.uk.xensource.com> <1349792847.21172.4479.camel@edumazet-glaptop> <1349793630.21847.208.camel@zakaz.uk.xensource.com> <1349863984.10070.26.camel@zakaz.uk.xensource.com> <1349874598.10070.39.camel@zakaz.uk.xensource.com> <748966751.20121010164949@eikelenboom.it> <1349942546.14806.7.camel@zakaz.uk.xensource.com> <151954917.20121011120004@eikelenboom.it> <1349949924.21172.8462.camel@edumazet-glaptop> <1349950494.14806.29.camel@zakaz.uk.xensource.com> <50A4540E.1010601@oracle.com> <1333495676.20121119164304@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig9491B69895AA4970D7941DA3"
Cc: ANNIE LI <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Marcos E. Matsunaga" <Marcos.Matsunaga@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49405 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809Ab2KTIag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 03:30:36 -0500
In-Reply-To: <1333495676.20121119164304@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9491B69895AA4970D7941DA3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 19.11.2012 16:43, Sander Eikelenboom wrote:
>=20
> Thursday, November 15, 2012, 3:31:42 AM, you wrote:
>=20
>> On 2012-10-11 18:14, Ian Campbell wrote:
>>> On Thu, 2012-10-11 at 11:05 +0100, Eric Dumazet wrote:
>>>> On Thu, 2012-10-11 at 12:00 +0200, Sander Eikelenboom wrote:
>>>>
>>>>> Probably due to the BUG_ON from the patch below, i changed it into =
a WARN_ON.
>>>>> And i seem to hit it, but only in one of the guests at the moment a=
nd it triggers quite irregularly.
>>>> xennet_make_frags() is able to split the skb->head in multiple page-=
size
>>>> chunks.
>>>>
>>>> It should do the same for fragments
>>> Right, I just want to be reproduce the issue so I can know I've fixed=
 it
>>> properly ;-)
>> Hi Ian,
>=20
>> I can reproduce this BUG_ON when running netperf/netserver test betwee=
n=20
>> two domus running on the same dom0. The domu and dom0 all use v3.7-rc1=
=2E
>=20
>> When I tried to rebase my persistent grant netfront/netback patch on=20
>> latest kernel, netperf/netserver test never succeeded. I did some test=
=20
>> to find out that v3.6-rc7 works fine, but v3.7-rc1, v3.7-rc2 and=20
>> v3.7-rc4 does not succeed in netperf/netserver test. So I keep my=20
>> persistent grant patch only based on v3.4-rc3 now.
>=20
>> Konrad thought about commit 6a8ed462f16b8455eec5ae00eb6014159a6721f0 i=
n=20
>> v3.7-rc1, and suggested me to test your debug patch in netfront. This =

>> BUG_ON happens soon after running the netperf/netserver test case.
>=20
>> Thanks
>> Annie
>=20
> Is there any progression with this bug (rc6 is out the door, so the rel=
ease of 3.7-final seems to be eminent and this bug completely cripples an=
y networking with guests) ?
>=20

+1 on that. I was testing yesterday with a PVM domU running 3.7-rc5 on Xe=
n 4.2
(but also reported from EC2 running Xen 3.4.3) c with one VCPU. I actuall=
y can
trigger it by just ssh'ing into the domU (from another machine) and then =
run
"find /". Output starts to stutter and then stops completely. When this h=
appens
a new connection still can be made and as long as only shorter output is
generated the ssh connection is ok. From a dump taken it looks like user-=
space
is waiting in some select call (without any warnon I rather won't see the=
 tx path).

-Stefan



--------------enig9491B69895AA4970D7941DA3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iQIcBAEBCgAGBQJQqz+kAAoJEOhnXe7L7s6juzcP/jOI3Ac4Nix8czBGsHJE9Rl5
R7icGSpb8Dpr8tWeWd3l5U0EYzcyARcfy6SKHYHcMEQth35nWsHdR55koB7ATzZZ
bZyooTSRGqsepuw9DWilgjvfR27zDFdymi/GIDaMVCIUxIvW0F+IVB++mstMUXZv
PTemlzKQtvflgIuDhia26sd6PfV/9AhmU757gzpMwuciStKuPgkBWEr6STnFQzEe
dCDCYCpFKYGcGRvnEsQT8p8ArLR9FEju/PmO1YjkSRiohTPGB1JFMSWTk83QIFj0
lU7c2FZr6DB7gC3ITTUERfw6kyPgkjIbK5qAVLUtJEjuqOueI9HZQ8qEuo9i4rdt
jRycw6Ff22qUCyKTvwcM9JK55GnFHmkUkC8n7hU4PRM2VuOS4+3K2o/Dia0vxgB0
JOvhRQFH2NfmJgeVIkbXpInu2WuRhFGtTEHA4HWF2MoBLaJYktKoqq8GS80+gLe2
pn31LUaj4NO/Ofb+7njY+dBiZLil4y3m02Qa0dVnuOcC58J5LaVAIYUhMhfGODCA
unB71Y0OP3pHahK7shd5sVmTZ72f6hL4paBEi6zFz0JvBdrAGDGth7uzzfXDxG30
cEyQUG0B7NexC3/WZhq1FDq1UsVcJHCly8Lp5CPkXPOdbchCqh3DukHlD12ozv2z
atR22nwyftzXhcTVvXE7
=zNki
-----END PGP SIGNATURE-----

--------------enig9491B69895AA4970D7941DA3--
