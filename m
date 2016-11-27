From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net: phy: realtek: fix enabling of the TX-delay for
 RTL8211F
Date: Sat, 26 Nov 2016 21:55:37 -0800
Message-ID: <bcc66892-4f2a-dab5-e820-29e2fc73683e@gmail.com>
References: <20161125131201.19994-1-martin.blumenstingl@googlemail.com>
 <20161125131201.19994-3-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
To: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161125131201.19994-3-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 11/25/2016 05:12 AM, Martin Blumenstingl wrote:
> The old logic always enabled the TX-delay when the phy-mode was set to
> PHY_INTERFACE_MODE_RGMII. There are dedicated phy-modes which tell the
> PHY driver to enable the RX and/or TX delays:
> - PHY_INTERFACE_MODE_RGMII should disable the RX and TX delay in the
>   PHY (if required, the MAC should add the delays in this case)
> - PHY_INTERFACE_MODE_RGMII_ID should enable RX and TX delay in the PHY
> - PHY_INTERFACE_MODE_RGMII_TXID should enable the TX delay in the PHY
> - PHY_INTERFACE_MODE_RGMII_RXID should enable the RX delay in the PHY
>   (currently not supported by RTL8211F)
> 
> With this patch we enable the TX delay for PHY_INTERFACE_MODE_RGMII_ID
> and PHY_INTERFACE_MODE_RGMII_TXID.
> Additionally we now explicity disable the TX-delay, which seems to be
> enabled automatically after a hard-reset of the PHY (by triggering it's
> reset pin) to get a consistent state (as defined by the phy-mode).
> 
> This fixes a compatibility problem with some SoCs where the TX-delay was
> also added by the MAC. With the TX-delay being applied twice the TX
> clock was off and TX traffic was broken or very slow (<10Mbit/s) on
> 1000Mbit/s links.
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
