From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: Fix use after free in phy_detach()
Date: Tue, 29 Nov 2016 20:35:40 -0500 (EST)
Message-ID: <20161129.203540.1821619500745777807.davem@davemloft.net>
References: <1480342711-26407-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, josh.cartwright@ni.com,
        nathan.sullivan@ni.com, zach.brown@ni.com,
        woojung.huh@microchip.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1480342711-26407-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Mon, 28 Nov 2016 15:18:31 +0100

> If device_release_driver(&phydev->mdio.dev) is called, it releases all
> resources belonging to the PHY device. Hence the subsequent call to
> phy_led_triggers_unregister() will access already freed memory when
> unregistering the LEDs.
> 
> Move the call to phy_led_triggers_unregister() before the possible call
> to device_release_driver() to fix this.
> 
> Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
> This is v2 of "[RFC] net: phy: Fix double free in phy_detach()".
> 
> v2:
>   - Dropped RFC,
>   - Reworded, as commit a7dac9f9c1695d74 ("phy: fix error case of
>     phy_led_triggers_(un)register") fixed the double free, and thus the
>     warning I was seeing during "poweroff" on sh73a0/kzm9g,
>   - Verified use after free using CONFIG_DEBUG_DEVRES, log_devres = 1,
>     and additional debug code printing the address of
>     phy->phy_led_triggers. Adding poisoning of freed memory to
>     devres_log() will cause a crash.

Applied, thanks.
