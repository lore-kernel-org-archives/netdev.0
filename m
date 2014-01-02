From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Thu, 02 Jan 2014 23:21:47 +0100
Message-ID: <52C5E67B.9070306@hauke-m.de>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>	<1388690342-27213-5-git-send-email-hauke@hauke-m.de> <CACna6rxrOOcb=xbeCytjWALAPOAj-P7Js5Xe7L1ykCimmDa4Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:52591 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499AbaABWV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 17:21:57 -0500
In-Reply-To: <CACna6rxrOOcb=xbeCytjWALAPOAj-P7Js5Xe7L1ykCimmDa4Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2014 09:40 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
>  > +       if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
>> +           ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {
>=20
> Please add a missing
> if (bgmac->phyaddr !=3D BGMAC_PHY_NOREGS)
> return;
> at the beginning of this 4707/53018 block

Why should I add that there?

>=20
>> +               bcma_awrite32(core, BCMA_IOCTL,
>> +                             bcma_aread32(core, BCMA_IOCTL) | 0x44)=
;
>=20
> Please use
> BGMAC_BCMA_IOCTL_SW_CLKEN | 0x40
> (unless you know 0x40, then replace it too).

The Documentation says this is:
* Bit 2 : TX_CLK_OUT_INVERT_EN - If set, this will invert the TX clock
out of AMAC.
And the other is:
* Bit 12:8  "interface_mode"  This field is programmed through IDM
control bits [6:2]

see this:
https://github.com/RMerl/asuswrt-merlin/blob/master/release/src-rt-6.x.=
4708/et/sys/etcgmac.c#L1039

>=20
>=20
>> +                       bgmac->mac_speed =3D SPEED_2500;
>> +                       bgmac->mac_duplex =3D DUPLEX_FULL;
>> +                       bgmac_mac_speed(bgmac);
>=20
> Wrong indent above.

fixed

>=20
>> @@ -911,7 +926,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac=
)
>>
>>         bcma_core_enable(core, flags);
>=20
> Look closer. Don't calculate flags and don't call bcma_core_enable fo=
r
> 4707 (but call it for 53018).

I haven't seen that condition, strange.
>=20
>=20
>> -       if (core->id.rev > 2) {
>> +       if (core->id.rev > 2 && ci->id !=3D BCMA_CHIP_ID_BCM4707 &&
>> +           ci->id !=3D BCMA_CHIP_ID_BCM53018) {
>=20
> Could you put 4707 check on the separated line? I'm not pushing howev=
er.

changed

Hauke
