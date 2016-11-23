From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] phy: fix error case of phy_led_triggers_(un)register
Date: Thu, 24 Nov 2016 00:55:07 +0300
Message-ID: <0cb4741c-7fce-973b-2b8d-7677329f440c@cogentembedded.com>
References: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com
To: Woojung.Huh@microchip.com, zach.brown@ni.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33836 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933083AbcKWWDX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 17:03:23 -0500
Received: by mail-lf0-f48.google.com with SMTP id o141so14454159lff.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 14:03:22 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/24/2016 12:39 AM, Woojung.Huh@microchip.com wrote:

> From: Woojung Huh <woojung.huh@microchip.com>
>
> When phy_init_hw() fails at phy_attach_direct();
> - phy_detach() calls phy_led_triggers_unregister() without
>   previous call of phy_led_triggers_register().
> - still call phy_led_triggers_register() and cause memory leak.
>
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/phy/phy_device.c       | 6 +++---
>  drivers/net/phy/phy_led_triggers.c | 3 +++
>  2 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 9e8f048..094a959 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -915,10 +915,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  	err = phy_init_hw(phydev);
>  	if (err)
>  		phy_detach(phydev);
> -	else
> +	else {

    CodingStyle: all *if* branches should have {} if at least one has {}.

>  		phy_resume(phydev);
> -
> -	phy_led_triggers_register(phydev);
> +		phy_led_triggers_register(phydev);
> +	}
>
>  	return err;
>
[...]

MBR, Sergei
