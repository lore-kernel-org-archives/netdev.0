From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCHv2 net-next 11/16] net: mvpp2: handle misc PPv2.1/PPv2.2
 differences
Date: Sat, 7 Jan 2017 13:12:35 +0100
Message-ID: <CAPv3WKeQ=fj2cKPyJ2NqCaAv55cOyWodujKwj3-v5iCrDYNcmA@mail.gmail.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170107110351.GK14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Yehuda Yitschak <yehuday@marvell.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Andrew Lunn <andrew@lunn.ch>, Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Mark Rutland <mark.rutland@arm.com>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170107110351.GK14217@n2100.armlinux.org.uk>
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

Hi Russel,

2017-01-07 12:03 GMT+01:00 Russell King - ARM Linux <linux@armlinux.org.uk>:
> On Wed, Dec 28, 2016 at 05:46:27PM +0100, Thomas Petazzoni wrote:
>> +#define MVPP22_SMI_MISC_CFG_REG                      0x2a204
>> +#define      MVPP22_SMI_POLLING_EN           BIT(10)
>> +
> ...
>> +     if (priv->hw_version == MVPP21) {
>> +             val = readl(priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
>> +             val |= MVPP2_PHY_AN_STOP_SMI0_MASK;
>> +             writel(val, priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
>> +     } else {
>> +             val = readl(priv->iface_base + MVPP22_SMI_MISC_CFG_REG);
>> +             val &= ~MVPP22_SMI_POLLING_EN;
>> +             writel(val, priv->iface_base + MVPP22_SMI_MISC_CFG_REG);
>> +     }
>
> The MVPP22_SMI_MISC_CFG_REG register is within the MDIO driver's
> register set, although the mvmdio driver does not access this register.
> Shouldn't this be taken care of by the mvmdio driver?
>
> Also, a point that I've noticed while reviewing this is the mvmdio
> driver also accesses these registers:
>
> #define MVMDIO_ERR_INT_CAUSE               0x007C
> #define MVMDIO_ERR_INT_MASK                0x0080
>
> in addition to the un-named register at offset 0.  The driver writes
> to these registers unconditionally when unbinding:
>
>         writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
>
> However, the various bindings for the driver have:
>
> arch/arm/boot/dts/armada-370-xp.dtsi:      compatible = "marvell,orion-mdio";
> arch/arm/boot/dts/armada-370-xp.dtsi-      reg = <0x72004 0x4>;
> arch/arm/boot/dts/armada-375.dtsi:         compatible = "marvell,orion-mdio";
> arch/arm/boot/dts/armada-375.dtsi-         reg = <0xc0054 0x4>;
> arch/arm/boot/dts/dove.dtsi:               compatible = "marvell,orion-mdio";
> arch/arm/boot/dts/dove.dtsi-               #address-cells = <1>;
> arch/arm/boot/dts/dove.dtsi-               #size-cells = <0>;
> arch/arm/boot/dts/dove.dtsi-               reg = <0x72004 0x84>;
> arch/arm/boot/dts/orion5x.dtsi:            compatible = "marvell,orion-mdio";
> arch/arm/boot/dts/orion5x.dtsi-            #address-cells = <1>;
> arch/arm/boot/dts/orion5x.dtsi-            #size-cells = <0>;
> arch/arm/boot/dts/orion5x.dtsi-            reg = <0x72004 0x84>;
> arch/arm/boot/dts/kirkwood.dtsi:           compatible = "marvell,orion-mdio";
> arch/arm/boot/dts/kirkwood.dtsi-           #address-cells = <1>;
> arch/arm/boot/dts/kirkwood.dtsi-           #size-cells = <0>;
> arch/arm/boot/dts/kirkwood.dtsi-           reg = <0x72004 0x84>;
> arch/arm/boot/dts/armada-38x.dtsi:         compatible = "marvell,orion-mdio";
> arch/arm/boot/dts/armada-38x.dtsi-         reg = <0x72004 0x4>;
>
> So, for many of these, we're accessing registers outside of the given
> binding, which sounds incorrect.  I guess that write should be
> conditional upon an interrupt being present.
>
> The binding document says:
>
> - reg: address and length of the SMI register
>
> which is clearly wrong for those cases where the interrupt is used.
>
> I also notice that the binding for CP110 uses a register size of 0x10
> (even in your tree) - but I guess this should be 4.
>
> I'm starting to wonder whether the orion-mdio driver really is a
> separate chunk of hardware that warrants a separate description in
> DT from the ethernet controller - it appears in all cases to be
> embedded with an ethernet controller, sharing its register space
> and at least some of the ethernet controllers clocks.  That says
> to me that it isn't an independent functional unit of hardware.
>

In fact there is common SMI bus, but each port has its own register
set to control it (it's true at least for Neta and PP2). There is also
an option to use HW polling - every 1s hardware checks PHY over SMI
and updates MAC registers of each port independently. I was able to
use those successfully in other implementations.

However we are supposed to use libphy in Linux and I'm afraid we have
to use single instance that controls single SMI bus - I think current
implementation is a compromise between HW and libphy demands.

Best regards,
Marcin
