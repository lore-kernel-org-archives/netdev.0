From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing PHY
Date: Mon, 30 Jan 2017 11:07:24 -0500
Message-ID: <CAC3K-4oYY0k4AUJ0o+SR9cySCZsqkLeK+gLvqxepgCuxqVKtYQ@mail.gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com> <20170128210832.26174-4-zajec5@gmail.com>
 <08f74e19-f9b2-a0ea-ee21-d35cbdf6ee76@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@openwrt.org>,
        Network Development <netdev@vger.kernel.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35291 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932130AbdA3QH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:07:26 -0500
Received: by mail-it0-f42.google.com with SMTP id 203so196961162ith.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 08:07:25 -0800 (PST)
In-Reply-To: <08f74e19-f9b2-a0ea-ee21-d35cbdf6ee76@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 10:08 PM, Florian Fainelli <f.fainelli@gmail.com> w=
rote:
>
>
> On 01/28/2017 01:08 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
>> From: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>>
>> This adds support for using bgmac with PHYs supported by standalone PHY
>> drivers. Having any PHY initialization in bgmac is hacky and shouldn't
>> be extended but rather removed if anyone has hardware to test it.
>>
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>> ---
>>  drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c | 10 ++++++++++
>>  1 file changed, 10 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c b/drivers/n=
et/ethernet/broadcom/bgmac-bcma-mdio.c
>> index 9d9984999dce..6ce80cbcb48e 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>> @@ -132,6 +132,10 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
>>       struct bcma_chipinfo *ci =3D &bgmac->bcma.core->bus->chipinfo;
>>       u8 i;
>>
>> +     /* For some legacy hardware we do chipset-based PHY initialization=
 here
>> +      * without even detecting PHY ID. It's hacky and should be cleaned=
 as
>> +      * soon as someone can test it.
>> +      */
>>       if (ci->id =3D=3D BCMA_CHIP_ID_BCM5356) {
>>               for (i =3D 0; i < 5; i++) {
>>                       bcma_mdio_phy_write(bgmac, i, 0x1f, 0x008b);
>> @@ -140,6 +144,7 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
>>                       bcma_mdio_phy_write(bgmac, i, 0x12, 0x2aaa);
>>                       bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
>>               }
>> +             return;
>
> That part is clearly initializing the built-in Ethernet switch's PHYs,
> and so the natural place for that would be to stick these init values
> into the Broadcom PHY driver. When b53-srab/b53_common attaches the
> switch, it will scan all of these port's builtin PHYs and bind to an
> appropriate PHY driver which could have this initialization as part of
> the config_init routine for instance. Right now, we are most likely
> using the Generic PHY.
>
> Here are the different PHY IDs you should read from these models if you
> want to make a subsequent patch that moves this initialization down to
> the Broadcom PHY driver:
>
> 5356: 0x03625DA0
> 5357/53572: 0x03625F00
> 4749: could either be 0x600D85F0 or the same as 53010 (0x600D8760),
> unclear where that product came from... Jon, would you know by chance?

The 4749 I have has a switch chip (bcm53115, according to the
datasheet).  So, I do not have any idea what PHYs this is referring
to.

> --
> Florian
