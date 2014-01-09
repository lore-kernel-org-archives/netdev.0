From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 2/7] ixgbe: Indicate removal state explicitly
Date: Thu, 9 Jan 2014 18:18:50 +0000
Message-ID: <D93A58B3-7AE5-4352-A727-730A854B675A@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
 <1389166847-3780-3-git-send-email-aaron.f.brown@intel.com>
 <79DAF37B-9AA5-407B-81D2-3EDFD8589254@gmail.com>
 <2537C4E1-5434-4C6B-95A1-2360BA0803FB@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4B27A891-3331-4A85-BD95-EBB9C0390143";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10626 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbaAISSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 13:18:52 -0500
In-Reply-To: <2537C4E1-5434-4C6B-95A1-2360BA0803FB@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_4B27A891-3331-4A85-BD95-EBB9C0390143
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 9, 2014, at 9:27 AM, Rustad, Mark D <mark.d.rustad@intel.com> =
wrote:

> On Jan 8, 2014, at 12:35 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>=20
>> On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> =
wrote:
>>=20
>>> From: Mark Rustad <mark.d.rustad@intel.com>
>>>=20
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h =
b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
>>> index 5e157ac..480c5c1 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
>>> @@ -124,6 +124,11 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw =
*hw);
>>> s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
>>> s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
>>>=20
>>> +#define IXGBE_FAILED_READ_REG 0xffffffffU
>>> +
>>> +void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
>>> +#define IXGBE_REMOVED(a) unlikely(!(a))
>>=20
>> IXGBE_REMOVED seems pretty closely tied to hw->hw_addr, but the macro =
turns any input into !input.  Maybe an inline that takes a *hw?
>=20
> An earlier version had two different inputs, but not any more. I will =
change it to take a hw parameter. Good suggestion.

Actually, I responded too quickly. Although my comment on there =
previously having been two different inputs was true, that isn't the =
real reason for this form. The reason is that the check needs to be done =
on the value retrieved by ACCESS_ONCE - the address that will be used =
for the access. If the parameter were hw, then a separate dereference =
could occur, which is definitely not wanted.

One could argue that the macro should just be eliminated and the =
expansion put everywhere, but I feel that the code is much clearer with =
the macro. Unless there is another suggestion, I think this should stay =
as it is in this series.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_4B27A891-3331-4A85-BD95-EBB9C0390143
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSzugIAAoJEDwO/+eO4+5u/SoP/jupnMbTXKMaJ/D+d96Maih1
nTPap1qXG9dNndsQJLY1NnkQZpjQ6Rpdp9fA5JzpK1C5nYBvVEjquB5pFhKKVLsg
ka4Mw2G8pg7EypIK5zYzF+oLauGPd7A/A+jhKUN5/oc0kKDpmdsLXgCyZt3G3Upv
HmxKq66sQGxQu7WrT9WzztJ4XNR0IIozoIKSQjdPScKG3bkyH3bn3GsVLiqMO7gd
FuPD3O8jSWmQcWBsMx/CPLBvt/cekrnS1tEOx5ZLFpTf7t7W4QCkYrQUxqq/mXBX
cvFC2UPWwutukTU2FclNVKgjU2Jg/cB2v4kDJ7BoR82WCi9l1NpVEc6b4hUG1tbO
FDEyKZ+JuXq9K4Ddryi4mABpt17wPEDztCo2oZ/RRofZkVR9BoKLQUygec1fBmCb
ZL1nBc2Wk9KUDN1eEGFe5J/qaZwWWHU3zm/csEFmtXNEiUzSG0H2DwRwFjIlIuko
/YJ2DiO1DOm8W1gUNS/EjXzE4aCFKNrbvKeQ8elGHuZaKeQDY3I0I1bx/obAoAyp
BI43zUb4ogaWk2dNU7PkMP9UZlupKoyJ/l+ij+w/rKgt0dQaxejxor1x9SC3p2Em
B8QkLuQAIzRgcHZyiVSxHFznUUdJ9+3y/cFgTLDbrU0a8TN6IzzWlNCE04TQd1TL
AvD0wzo8HrNfUULCl7S9
=41V0
-----END PGP SIGNATURE-----

--Apple-Mail=_4B27A891-3331-4A85-BD95-EBB9C0390143--
