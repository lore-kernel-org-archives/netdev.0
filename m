From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 2/7] ixgbe: Indicate removal state explicitly
Date: Thu, 9 Jan 2014 17:27:44 +0000
Message-ID: <2537C4E1-5434-4C6B-95A1-2360BA0803FB@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
 <1389166847-3780-3-git-send-email-aaron.f.brown@intel.com>
 <79DAF37B-9AA5-407B-81D2-3EDFD8589254@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D42A5925-20F1-4056-95B1-892C0C47B53D";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21555 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752354AbaAIR1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 12:27:47 -0500
In-Reply-To: <79DAF37B-9AA5-407B-81D2-3EDFD8589254@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_D42A5925-20F1-4056-95B1-892C0C47B53D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 8, 2014, at 12:35 AM, Scott Feldman <sfeldma@gmail.com> wrote:

> On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> =
wrote:
>=20
>> From: Mark Rustad <mark.d.rustad@intel.com>
>>=20
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h =
b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
>> index 5e157ac..480c5c1 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
>> @@ -124,6 +124,11 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw =
*hw);
>> s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
>> s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
>>=20
>> +#define IXGBE_FAILED_READ_REG 0xffffffffU
>> +
>> +void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
>> +#define IXGBE_REMOVED(a) unlikely(!(a))
>=20
> IXGBE_REMOVED seems pretty closely tied to hw->hw_addr, but the macro =
turns any input into !input.  Maybe an inline that takes a *hw?

An earlier version had two different inputs, but not any more. I will =
change it to take a hw parameter. Good suggestion.

<snip>

>> @@ -2970,7 +2999,7 @@ void ixgbe_configure_tx_ring(struct =
ixgbe_adapter *adapter,
>> 			ring->count * sizeof(union ixgbe_adv_tx_desc));
>> 	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
>> 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
>> -	ring->tail =3D hw->hw_addr + IXGBE_TDT(reg_idx);
>> +	ring->tail =3D adapter->io_addr + IXGBE_TDT(reg_idx);
>=20
> How is this related to the commit msg about register reads?  Seems =
like two patches.

No, it is theoretically possible for hw_addr to be NULL now if a removal =
was somehow detected, so using the new io_addr that will never be NULL =
is safer. The possibility of hw_addr being NULL is introduced by these =
patches, so this change should be a part of these patches.

<snip>

Sorry for the duplicate Scott. You may have noticed that I failed to =
copy everyone else as I should have.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_D42A5925-20F1-4056-95B1-892C0C47B53D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSztwPAAoJEDwO/+eO4+5uanIQALXBV65AvRE9gH5pTPt7mNLK
Gg6yFNah5LE0UbMX6xBI6Ok48dFluR/usnWVxcCMNMs4K6+lhegs6bqGaempv8KH
6yaeU+rxl9Y82uAtSxZIHQ25gbeLNTNes6NcsrkhKh/rhX9GICtGbzKaBHDqaANQ
nsYPc5NYXBiD8RD/5EIyKO+DpVKse1eEwSG8KSUtRj/QTu/y80fvuDMEHeKmIWPW
LPqUxCw2zp888+9WjleChHoYQGKU0zp0ionhrGeE7tz03R68bH9p8lp9hv+3GB0X
R/v1BnjFb/PQqVLHn+dQeSmJcnTOgbVs+bBC+0F/Hup79amCdOndsiNZe9L/nQzz
dh9YANhCWyXG8KrYtCOa439d6vWT7xxmLvDEJpxqz1jPbvuvN+Dl+I/YlWd37sT9
57FHTCZktR9tuAkcFJF01r0ASp5U+TNrwjCKO8myZep/3OgSjK8geV42yKVQwUik
KDxgTgUjwrMMG393GveLBKoqoebopkOOF4yCLFXEub+ug7PSyQTCO7RGCddgM3ts
tvGNRaTkxwPGw3Hnx3V06s1LFXsVnrNXliefPNxlceYQGNWgXNLDl1G7EDvu60/A
sE+bqmXJp40JjfKmpdLRG7+cB98JTojMLPY7ZXTEqaCPyi602Or1/JLD7oD7YVqQ
oe//FMXiV55hO/nOIcbq
=tCP2
-----END PGP SIGNATURE-----

--Apple-Mail=_D42A5925-20F1-4056-95B1-892C0C47B53D--
