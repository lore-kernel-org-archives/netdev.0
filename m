From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 19:53:39 +0200
Message-ID: <5167289.0a4LBoWhyX@wuerfel>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <20160426121335.GC11668@lunn.ch> <571FA3F6.7000903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Punit Agrawal <punit.agrawal@arm.com>, Anup Patel <anup.patel@broadcom.com>,
 Pawel Moll <pawel.moll@arm.com>, devicetree@vger.kernel.org,
 Catalin Marinas <catalin.marinas@arm.com>,
 Suzuki K Poulose <suzuki.poulose@arm.com>, Will Deacon <will.deacon@arm.com>,
 Chen-Yu Tsai <wens@csie.org>, linux-kernel@vger.kernel.org,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Pramod Kumar <pramod.kumar@broadcom.com>, Rob Herring <robh+dt@kernel.org>,
 BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
 netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
 linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <571FA3F6.7000903@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 April 2016 10:23:02 Florian Fainelli wrote:
> On 26/04/16 05:13, Andrew Lunn wrote:
> >> 4. Apart from these, by using MDIO mux framework we are making our
> >> non-ethernet PHYs dependent on Linux network drivers which is not
> >> acceptable. What if some product line does not need network subsystem at
> >> all?
> > 
> > This is your only valid point. However, does Broadcom have a product
> > line which does not include networking? Is not Broadcom a network SoC
> > vendor?
> 
> But even with that, there is no reason why we could not decouple the
> PHYLIB MDIO framework from PHYLIB and make it available as a more
> standalone subsystem which can be utilized when you have a mix of MDIO
> devices like here.

[adding Kishon Vijay Abraham]

We should also consider how this fits in with drivers/phy/, which is
the generic framework for all PHY devices that are not for ethernet.

The most straightforward way that you mention would be to allow
generic PHY devices to be probed on an MIO bus or mux. This should
just work using mdio_module_driver(), as Andrew already explained.

A more complex problem would be having a PHY driver for a device
that can be either an ethernet phy or some other phy. With today's
frameworks that would require two separate drivers, one in drivers/phy
and one in drivers/net/phy/. If that turns out to be a common problem,
we might want to come up with a way to nest one on top of the other,
or merge two two device structures (struct phy_device and struct phy).

> I am not clear on how common a shared MDIO bus is on other SoCs, but the
> other Broadcom SoCs I am familiar with have dedicated MDIO buses
> instances per type of PHY (PCIe, BUSB, Ethernet), thus making the split
> a ton easier.

I think most commonly, the other PHYs are not on MDIO at all, but are
integrated inside of the SoC as an MMIO based device.

	Arnd
