From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Wed, 25 Nov 2015 17:12:35 +0000
Message-ID: <4F7AD1BB-DF5D-4391-88F4-F0599A2AF90C@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <1448412212.20113.12.camel@perches.com> <1448448411.3154.32.camel@intel.com>
 <1448449102.20113.28.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_C1B52C2F-AFA5-44C4-BCD5-92D49349BB95";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Joe Perches" <joe@perches.com>
To: "Zhang, Helin" <helin.zhang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13872 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbbKYRMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 12:12:38 -0500
In-Reply-To: <1448449102.20113.28.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_C1B52C2F-AFA5-44C4-BCD5-92D49349BB95
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

Joe Perches <joe@perches.com> wrote:

> On Wed, 2015-11-25 at 02:46 -0800, Jeff Kirsher wrote:
>> On Tue, 2015-11-24 at 16:43 -0800, Joe Perches wrote:
>>> On Tue, 2015-11-24 at 16:04 -0800, Jeff Kirsher wrote:
>>>> From: Helin Zhang <helin.zhang@intel.com>
>>>>=20
>>>> Pointer of type void * shouldn't be used in arithmetic, which may
>>>> result in compilation error. Casting of (u8 *) can be added to fix
>>>> that.
>>>=20
>>> void * arithmetic is used quite frequently in the kernel.
>>>=20
>>> What compiler emits an error?
>>=20
>> When you use the gcc -Wpointer-arith, it generates the warning.
>=20
> make W=3D3 does that
>=20
> $ make help
> [...]
> make W=3Dn   [targets] Enable extra gcc checks, n=3D1,2,3 where
> 		1: warnings which may be relevant and do not occur too =
often
> 		2: warnings which occur quite often but may still be =
relevant
> 		3: more obscure warnings, can most likely be ignored
>=20
> but I think it should be ignored.

Yes. That doesn't mean that -Wpointer-arith can't catch other possible =
errors that may be worth fixing, but this particular type is an accepted =
usage in the kernel and so should be ignored - unless you find something =
logically wrong, which does not seem to be the case here at all.

If one cared about portability to other compilers that treat void * very =
differently in this usage, then you would want to deal with all of =
these. That is not the case with the kernel.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_C1B52C2F-AFA5-44C4-BCD5-92D49349BB95
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWVewGAAoJEDwO/+eO4+5un6YP/2Y4tE7KktZ9HTSUj4vpXJbD
KHREl4kO+X/6KeFDvhl78TdFlFwyjZKGTIiBxaaOTN02Zmo3iUXvzy7mao15KN9i
EhZg5f8Ui2PFdOjGIiP4XC2tzW07eJ+8etxHa63l7+4mtl+Qd+3Dh/fNtNRfaUK8
4AwghxTdhMteIx/X+pelRoxlUXAeM28//TXKzzvuvnSkjR/zIX+DGH7zCahRtWz7
qLW3WlD6uz/eC6wz/1wlFlSTTjkdwBPqh06keRi4yNma1Z30qG3FXgp5MBPhtAzH
S8EAOnNcxLcI5LN2xbmv5blw/HBD5JMRlR0rRa2dbx+M4eTPttRNZUZp8sHPqeDo
pzFF0BwnVAR1mmCTVdPfeRz5nrL8cin/upLnOdIQN5I0LcL/NwX4ZHg6tq8iDVu/
W1+u3olSFSyWdmmwDWIh6n7tuXLCtjQ2nVpu7emsOiqpuQ6fsRd+UoSxWBx1g96u
H4MVsZHsHGkFmI3rYyXjVgUYDtAtg5JOIH7IsSnthLdUoguYOo5QCBUYoRjD2wOt
BRpayLQziaF3703tSdxY2BXTWZHy4/dyLQGCNtT+qP06JzBENlhH6bGy/z6b3nmZ
kNP8a5rtOZ2n/aYNwi0uX+p9yC0WKcTkN6/TAQ6fXZJ4lBN6ucwnS1w6MGdQW+5T
4OBb33xU1OECLLg7Axil
=3aL6
-----END PGP SIGNATURE-----

--Apple-Mail=_C1B52C2F-AFA5-44C4-BCD5-92D49349BB95--
