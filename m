From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: re-apply PHY fixups during phy_register_device
Date: Mon, 28 Jul 2014 15:14:42 -0700
Message-ID: <CAGVrzcZp2wYdfJfZAcgmM3gizstXLWMuT9vAxyHWTayBi+jZ=g@mail.gmail.com>
References: <1406584645-20081-1-git-send-email-f.fainelli@gmail.com> <20140729001306.00000332@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Jonas Gorski <jogo@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35615 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbaG1WPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 18:15:23 -0400
Received: by mail-oi0-f52.google.com with SMTP id h136so6564845oig.25
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 15:15:22 -0700 (PDT)
In-Reply-To: <20140729001306.00000332@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-28 15:13 GMT-07:00 Jonas Gorski <jogo@openwrt.org>:
> On Mon, 28 Jul 2014 14:57:25 -0700
> Florian Fainelli <f.fainelli@gmail.com> wrote:
>
>> Commit 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
>> moved the call to phy_scan_fixups() in phy_init_hw() after a software
>> reset is performed.
>>
>> This broke PHY drivers which do register an early PHY fixup callback to
>> intercept the PHY probing and do things like changing the 32-bits unique
>> PHY identifier when a pseudo-PHY address has been used.
>>
>> Reported-by: Hauke Mehrtens <hauke@hauke-m.de>
>> Reported-by: Jonas Gorski <jogo@openwrt.org>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> This changes is applicable to 3.14+ thanks!
>>
>>  drivers/net/phy/phy_device.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 74a82328dd49..1759d54682c8 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -355,6 +355,7 @@ int phy_device_register(struct phy_device *phydev)
>>       phydev->bus->phy_map[phydev->addr] = phydev;
>>
>>       /* Run all of the fixups for this PHY */
>> +     phy_scan_fixups(phydev);
>>       err = phy_init_hw(phydev);
>
> You can safely remove the call to phy_init_hw(), as it will do nothing:
>
> int phy_init_hw(struct phy_device *phydev)
> {
>         int ret = 0;
>
>         if (!phydev->drv || ...) <- always true at this point
>                 return 0;
>
>
> Also you should check the return value of phy_scan_fixups.
>
>>       if (err) {
>>               pr_err("PHY %d failed to initialize\n", phydev->addr);
>
> So this can be actually hit.

Good catch, I will resubmit a v2 shortly, thanks!
-- 
Florian
