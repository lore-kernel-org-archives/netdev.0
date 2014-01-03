From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Fri, 3 Jan 2014 07:13:30 +0100
Message-ID: <CACna6rzgno_pQQkP018snvS7rKDgoNzaufx4WphEnOXhs53v0A@mail.gmail.com>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
	<1388690342-27213-5-git-send-email-hauke@hauke-m.de>
	<CACna6rxrOOcb=xbeCytjWALAPOAj-P7Js5Xe7L1ykCimmDa4Sw@mail.gmail.com>
	<52C5E67B.9070306@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:54650 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbaACGNb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 01:13:31 -0500
Received: by mail-ob0-f182.google.com with SMTP id wp4so15260526obc.41
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 22:13:30 -0800 (PST)
In-Reply-To: <52C5E67B.9070306@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/2 Hauke Mehrtens <hauke@hauke-m.de>:
> On 01/02/2014 09:40 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
>>  > +       if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
>>> +           ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {
>>
>> Please add a missing
>> if (bgmac->phyaddr !=3D BGMAC_PHY_NOREGS)
>> return;
>> at the beginning of this 4707/53018 block
>
> Why should I add that there?

This is what I can see in etcgmac.c version:
* $Id: etcgmac.c 414031 2013-07-23 10:54:51Z $


>>> +               bcma_awrite32(core, BCMA_IOCTL,
>>> +                             bcma_aread32(core, BCMA_IOCTL) | 0x44=
);
>>
>> Please use
>> BGMAC_BCMA_IOCTL_SW_CLKEN | 0x40
>> (unless you know 0x40, then replace it too).
>
> The Documentation says this is:
> * Bit 2 : TX_CLK_OUT_INVERT_EN - If set, this will invert the TX cloc=
k
> out of AMAC.
> And the other is:
> * Bit 12:8  "interface_mode"  This field is programmed through IDM
> control bits [6:2]
>
> see this:
> https://github.com/RMerl/asuswrt-merlin/blob/master/release/src-rt-6.=
x.4708/et/sys/etcgmac.c#L1039

Documentation is about "BCM4707 GMAC DevStatus register" which is:
#define BGMAC_DEV_CTL
That explains why you can't execute:
devstatus =3D R_REG(ch->osh, &regs->devstatus);
mode =3D ((devstatus & DS_MM_MASK) >> DS_MM_SHIFT);
code/path on BCM4707 family.

si_core_cflags -> ai_core_cflags operates on ai->ioctrl register (and
so does bcma_awrite32), so these documented bits don't apply to it.

--=20
Rafa=C5=82
