From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Thu, 2 Jan 2014 21:40:00 +0100
Message-ID: <CACna6rxrOOcb=xbeCytjWALAPOAj-P7Js5Xe7L1ykCimmDa4Sw@mail.gmail.com>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
	<1388690342-27213-5-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:60273 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaABUkA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:40:00 -0500
Received: by mail-ob0-f179.google.com with SMTP id wm4so14832832obc.38
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 12:40:00 -0800 (PST)
In-Reply-To: <1388690342-27213-5-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +       if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
> +           ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {

Please add a missing
if (bgmac->phyaddr !=3D BGMAC_PHY_NOREGS)
return;
at the beginning of this 4707/53018 block


> +               bcma_awrite32(core, BCMA_IOCTL,
> +                             bcma_aread32(core, BCMA_IOCTL) | 0x44);

Please use
BGMAC_BCMA_IOCTL_SW_CLKEN | 0x40
(unless you know 0x40, then replace it too).


> +                       bgmac->mac_speed =3D SPEED_2500;
> +                       bgmac->mac_duplex =3D DUPLEX_FULL;
> +                       bgmac_mac_speed(bgmac);

Wrong indent above.


> @@ -911,7 +926,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
>
>         bcma_core_enable(core, flags);

Look closer. Don't calculate flags and don't call bcma_core_enable for
4707 (but call it for 53018).


> -       if (core->id.rev > 2) {
> +       if (core->id.rev > 2 && ci->id !=3D BCMA_CHIP_ID_BCM4707 &&
> +           ci->id !=3D BCMA_CHIP_ID_BCM53018) {

Could you put 4707 check on the separated line? I'm not pushing however=
=2E

--=20
Rafa=C5=82
