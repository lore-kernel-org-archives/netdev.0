From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 21:41:02 +0200
Message-ID: <20160426194102.GF30107@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <5167289.0a4LBoWhyX@wuerfel>
 <20160426182335.GE30107@lunn.ch>
 <9424602.Vqb0FY56gH@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	netdev@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>,
	linux-kernel@vger.kernel.org,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	linux-arm-kernel@lists.infradead.org,
	Anup Patel <anup.patel@broadcom.com>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9424602.Vqb0FY56gH@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 09:24:34PM +0200, Arnd Bergmann wrote:
> On Tuesday 26 April 2016 20:23:35 Andrew Lunn wrote:
> > > A more complex problem would be having a PHY driver for a device
> > > that can be either an ethernet phy or some other phy.
> > 
> > I doubt that ever happens. You can have up to 32 different devices on
> > an MDIO bus. Since an Ethernet PHY and a "some other sort of PHY" are
> > completely different things, why would a hardware engineer place them
> > on the same address? It is like saying your ATA controller and VGA
> > controller share the same slot on the PCI bus...
> 
> To clarify: what I meant is a device that is designed as a PHY for
> similar hardware (e.g. SATA, USB3 and PCIe) and that has a common
> register set and a single driver, but that driver can operate
> in multiple modes. You typically have multiple instances of
> such hardware, with each instance linked to exactly one host
> device, but one driver for all of them.
> 
> See Documentation/devicetree/bindings/phy/apm-xgene-phy.txt
> and drivers/phy/phy-xgene.c for one such example.

Interesting. Also, that this lists SGMII. I assume this is a phy in
the MAC in order to talk to the Ethernet PHY.

I still don't see it being a big problem if a phy driver implements an
Ethernet PHY. It just needs to call phy_device_create() and
phy_device_register().

	Andrew
