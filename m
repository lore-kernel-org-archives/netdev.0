From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Mon, 25 Apr 2016 22:56:50 +0200
Message-ID: <20160425205650.GA31129@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Suzuki K Poulose <suzuki.poulose-5wv7dgnIgG8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Punit Agrawal <punit.agrawal-5wv7dgnIgG8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Anup Patel <anup.patel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461230323-27891-2-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Pramod

I took a closer look. I don't see why the current MDIO code should not
be used, rather than adding a new framework.

What you need for your Non Ethernet PHYs is that they are somehow
probed. The current MDIO code will do that, based on the compatible
string. An mdio device gets passed a struct mdio_device * to its probe
function, giving you the bus and address on the bus for the
device. Your PHY driver can then register itself using
devm_of_phy_provider_register(). The user of the PHY then needs to use
devm_phy_get() to get a handle on the phy, and can then use
phy_power_on()/phy_power_off().

There is a very simple example here for an MDIO device driver:

http://thread.gmane.org/gmane.linux.network/393532

The muxing of the MDIO busses looks a little tricky. At the moment you have:

    writel(cmd, base + MDIO_PARAM_OFFSET);

which mixes together the muxing parameters and the write value. Can
this register be accessed as two 16 bit registers? If it can be, you
can cleanly separate out the muxing.

Take a look at mdio-mux-gpio.c and mdio-mux-mmioreg.c for examples of
MDIO muxes.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
