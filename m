From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 14:13:35 +0200
Message-ID: <20160426121335.GC11668@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com>
 <20160425205650.GA31129@lunn.ch>
 <666dffb41a922b0c8638f2f002a2de08@mail.gmail.com>
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
In-Reply-To: <666dffb41a922b0c8638f2f002a2de08-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 02:03:27PM +0530, Pramod Kumar wrote:
> Hi Andrew,
> 
> Thanks for reviewing. I really appreciate your effort it.
> 
> I am already aware of MDIO mux framework but did not see it fit for our
> use case due to below limitations:
> 
> 1.  Current MDIO mux framework is Ethernet centric and it is only meant to
> mux multiple MII buses using same MDIO controller.  This means it is only
> meant for MII-compliant PHY devices (i.e. PHY devices having registers
> as-per MII specs).

Nope, this is wrong. You can have a mixture of PHYs and other MDIO
devices on the MII bus. The framework does not care. A PHY is a
special case of an MDIO device.

> 2.  The MDIO mux framework registers each child bus as MII bus. The Linux
> Ethernet MDIO framework will scan for all attached PHY devices on given
> MII bus and try to read MII PHY_ID register which is not present in all
> Broadcom non-ethernet PHYs.

It only performs a scan if you don't list the devices in the device
tree. If you do list devices, and include the address on the bus, it
never scans.

A good example of this is Ethernet switches. They occupy multiple
addresses on the MDIO bus, and also do not implement the PHY_ID
register at each address. Yet the MDIO layer is happy with this.

> 3. Let's say we ignore point1 and point2 above  and go ahead and use MDIO
> mux framework then we will still have to emulated MII PHY_ID read for
> non-ethernet PHYs.

Nope. Not at all. You have an MDIO device on the bus, not an Ethernet
PHY. Hence the device is not liked to the PHY state machine, etc.

The key concept to get here is that there are MDIO devices, and a
subset of MDIO devices are Ethernet PHYs.....

> 4. Apart from these, by using MDIO mux framework we are making our
> non-ethernet PHYs dependent on Linux network drivers which is not
> acceptable. What if some product line does not need network subsystem at
> all?

This is your only valid point. However, does Broadcom have a product
line which does not include networking? Is not Broadcom a network SoC
vendor?

> 
> As you can see from above points, trying to re-use Linux Ethernet MDIO mux
> framework for non-Ethernet PHYs is not the right way.

And as i pointed out, all your arguments are wrong, bar one. And i
doubt that one argument is sufficient to duplicate a lot of code which
already exists and does 95% of what you need.

> I'll add PCIe PHYs driver based on Shared MDIO framework in next patch
> revision to get a feel of its need.

Great. Lets then see what is needed to turn it into an MDIO device.

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
