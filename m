From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Add watchdog interrupt
 handler
Date: Sat, 4 Feb 2017 18:33:20 -0800
Message-ID: <6936eb05-bec7-a898-6dae-875eda888ce1@gmail.com>
References: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33143 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbdBECdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 21:33:23 -0500
Received: by mail-oi0-f68.google.com with SMTP id j15so4246297oih.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 18:33:23 -0800 (PST)
In-Reply-To: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/04/17 à 12:38, Andrew Lunn a écrit :
> The switch contains a watchdog looking for issues with the internal
> gubbins of the switch. Hook the interrupt the watchdog triggers and
> log the value of the control register indicating why the watchdog
> fired. The watchdog can only be cleared with a switch reset, which
> will destroy the current configuration. Rather than doing this, just
> disable the interrupt.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6xxx/global2.c   | 64 ++++++++++++++++++++++++++++++++++-
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  9 +++++
>  2 files changed, 72 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
> index 50e4e0be4227..8013d8e18e3f 100644
> --- a/drivers/net/dsa/mv88e6xxx/global2.c
> +++ b/drivers/net/dsa/mv88e6xxx/global2.c
> @@ -649,6 +649,66 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
>  	return mv88e6xxx_g2_smi_phy_write_c22(chip, addr, reg, val, external);
>  }
>  
> +static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
> +{
> +	u16 reg;
> +
> +	struct mv88e6xxx_chip *chip = dev_id;
> +
> +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
> +
> +	dev_info(chip->dev, "Watchdog event: %04x", reg);

Should this be 0x%04x just to illustrate the value is hexadecimal? And
should this be dev_info_once()?
-- 
Florian
