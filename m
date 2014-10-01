From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: phy: add BCM7425 and BCM7429 PHYs
Date: Wed, 1 Oct 2014 11:44:54 -0700
Message-ID: <CAGXr9JF=PuuE9-AYDsoNeAuAWa8=DDMPLHNqDiTODg3LFNxOdg@mail.gmail.com>
References: <20141001183102.DF007100A08@puck.mtv.corp.google.com>
	<542C4929.8060802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:51668 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbaJASoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:44:55 -0400
Received: by mail-vc0-f181.google.com with SMTP id le20so728968vcb.12
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 11:44:54 -0700 (PDT)
In-Reply-To: <542C4929.8060802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Wed, Oct 1, 2014 at 11:34 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hello Petri,
>
> This looks good to me, some minor comments below
>
> On 10/01/2014 11:31 AM, Petri Gynther wrote:
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>> ---
>>  drivers/net/phy/bcm7xxx.c | 28 ++++++++++++++++++++++++++++
>>  include/linux/brcmphy.h   |  2 ++
>>  2 files changed, 30 insertions(+)
>>
>> diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
>> index daae699..0ae90f1 100644
>> --- a/drivers/net/phy/bcm7xxx.c
>> +++ b/drivers/net/phy/bcm7xxx.c
>> @@ -350,6 +350,32 @@ static struct phy_driver bcm7xxx_driver[] = {
>>       BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
>>       BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
>>  {
>> +     .phy_id         = PHY_ID_BCM7425,
>> +     .phy_id_mask    = 0xffffffff,
>
> The last 4 bits contain the revision, although we never increased it, it
> is safer to match with 0xffff_fff0. If that means dropping the catch all
> 40nm entry, that's fine by me.
>
OK. Will fix.

>> +     .name           = "Broadcom BCM7425 External PHY",
>
> Just use "Broadcom BCM7425" here, for consistency with the other
> entries, and since that's really the internal PHY of the chip.
>
OK.

>> +     .features       = PHY_GBIT_FEATURES |
>> +                       SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>> +     .flags          = 0,
>> +     .config_init    = bcm7xxx_config_init,
>> +     .config_aneg    = genphy_config_aneg,
>> +     .read_status    = genphy_read_status,
>> +     .suspend        = bcm7xxx_suspend,
>> +     .resume         = bcm7xxx_config_init,
>> +     .driver         = { .owner = THIS_MODULE },
>> +}, {
>> +     .phy_id         = PHY_ID_BCM7429,
>> +     .phy_id_mask    = 0xffffffff,
>> +     .name           = "Broadcom BCM7429 Internal PHY",
>
> Same thing here.
>
OK.

>> +     .features       = PHY_GBIT_FEATURES |
>> +                       SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>> +     .flags          = PHY_IS_INTERNAL,
>> +     .config_init    = bcm7xxx_config_init,
>> +     .config_aneg    = genphy_config_aneg,
>> +     .read_status    = genphy_read_status,
>> +     .suspend        = bcm7xxx_suspend,
>> +     .resume         = bcm7xxx_config_init,
>> +     .driver         = { .owner = THIS_MODULE },
>> +}, {
>>       .phy_id         = PHY_BCM_OUI_4,
>>       .phy_id_mask    = 0xffff0000,
>>       .name           = "Broadcom BCM7XXX 40nm",
>> @@ -381,6 +407,8 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
>>       { PHY_ID_BCM7250, 0xfffffff0, },
>>       { PHY_ID_BCM7364, 0xfffffff0, },
>>       { PHY_ID_BCM7366, 0xfffffff0, },
>> +     { PHY_ID_BCM7425, 0xffffffff, },
>> +     { PHY_ID_BCM7429, 0xffffffff, },

I need to adjust these masks as well.

>>       { PHY_ID_BCM7439, 0xfffffff0, },
>>       { PHY_ID_BCM7445, 0xfffffff0, },
>>       { PHY_BCM_OUI_4, 0xffff0000 },
>> diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
>> index 3f626fe..666132e 100644
>> --- a/include/linux/brcmphy.h
>> +++ b/include/linux/brcmphy.h
>> @@ -16,6 +16,8 @@
>>  #define PHY_ID_BCM7250                       0xae025280
>>  #define PHY_ID_BCM7364                       0xae025260
>>  #define PHY_ID_BCM7366                       0x600d8490
>> +#define PHY_ID_BCM7425                       0x03625e69

This should then be 0x03625e60, right?

>> +#define PHY_ID_BCM7429                       0x600d8731

And this 0x600d8730?

>>  #define PHY_ID_BCM7439                       0x600d8480
>>  #define PHY_ID_BCM7445                       0x600d8510
>>
>>
>

-- Petri
