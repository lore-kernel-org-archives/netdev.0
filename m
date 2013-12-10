From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] bgmac: drop duplicated PHY defines
Date: Tue, 10 Dec 2013 09:53:28 -0800
Message-ID: <CAGVrzcbYv=9W_0nYh_6G0m8G6CdkhAWaYuoynAcBYCrXs8Tnpg@mail.gmail.com>
References: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
 <CAGVrzcYCT0QUKuRGktH-4xVrXtort-Uy4phvq8yZg3nU8SPFjw@mail.gmail.com> <CACna6rzRVQYrOnnJQiHE83d+aj6Hf693gnLY-m-iWffffzD3jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:37005 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab3LJRyI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:54:08 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so7796657pdj.30
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:54:08 -0800 (PST)
In-Reply-To: <CACna6rzRVQYrOnnJQiHE83d+aj6Hf693gnLY-m-iWffffzD3jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> 2013/12/10 Florian Fainelli <f.fainelli@gmail.com>:
>> Hello Rafal
>>
>> 2013/12/10 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>>> ---
>>>  drivers/net/ethernet/broadcom/bgmac.c |    6 ++----
>>>  drivers/net/ethernet/broadcom/bgmac.h |   21 ---------------------
>>>  2 files changed, 2 insertions(+), 25 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/et=
hernet/broadcom/bgmac.c
>>> index 0452937..ad4b2f1 100644
>>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>>> @@ -725,11 +725,9 @@ static void bgmac_phy_reset(struct bgmac *bgma=
c)
>>>         if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
>>>                 return;
>>>
>>> -       bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
>>> -                       BGMAC_PHY_CTL_RESET);
>>> +       bgmac_phy_write(bgmac, bgmac->phyaddr, MII_BMCR, BMCR_RESET=
);
>>>         udelay(100);
>>> -       if (bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) &
>>> -           BGMAC_PHY_CTL_RESET)
>>> +       if (bgmac_phy_read(bgmac, bgmac->phyaddr, MII_BMCR) & BMCR_=
RESET)
>>>                 bgmac_err(bgmac, "PHY reset failed\n");
>>>         bgmac_phy_init(bgmac);
>>
>> phy_init_hw() now issues a PHY reset through BMCR_RESET, you might
>> want to use it instead of this here:
>>
>> - the 100 microseconds delay might not be sufficient for all PHYs ou=
t there
>> - any PHY fixup (although there are none for BCM47xx yet) would be
>> wiped out by this "wild" PHY reset
>>
>> This is quite new, so I do not expect you knew about this.
>
> Thanks for pointing that! I was looking for BMCR_RESET usages with:
> http://lxr.free-electrons.com/ident?v=3D3.12;i=3DBMCR_RESET
> but it didn't find any interesting (because it uses 3.12 kernel sourc=
es).
>
> This udelay is from specs based on Broadcom's code. What you have in
> phy_poll_reset sounds indeed much more sane.
>
> If you take a look at bgmac_phy_init, it actually has kind of fixups.
> They are just programmed per-Broadcom chip id and not per PHY id as
> you normally do that with phy_register_fixup_for_uid. But I think we
> should be able to workaround that.
>
> So I fully agree we should use phy_init_hw, but I think we should
> implement that in a separated patch and on top of PHY cleanups I
> recently did. Just to simplify bisecting potential regressions.

Sounds good!

>
> Are you OK with applying this patch as-is and working on another one
> cleaning PHY reset/init in a nicer way?

Oh yes, this patch just made me look at the code, but your cleanups
are good. Thanks!
--=20
=46lorian
