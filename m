From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v0 06/10] arm: orion5x: Add DT-based support for Netgear
 WNR854T
Date: Mon, 18 Jul 2016 12:06:26 +0200
Message-ID: <1792384.6N9lHjmBFc@wuerfel>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <6404488.GyOP57DJrV@wuerfel> <20160718114424.14a28889@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, devicetree@vger.kernel.org,
 netdev@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160718114424.14a28889@free-electrons.com>
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

On Monday, July 18, 2016 11:44:24 AM CEST Thomas Petazzoni wrote:
> 
> On Sun, 17 Jul 2016 22:41:35 +0200, Arnd Bergmann wrote:
> 
> > I would assume that the PCIe port should work out of the box with the driver
> 
> Unfortunately, no. The PCIe on Orion5x requires a workaround for
> reading/writing the PCI configuration space. Instead of doing MMIO
> accesses to PCIE_CONF_ADDR_OFF / PCIE_CONF_DATA_OFF, you must map a
> MBus window, which provides a memory-mapped view of the PCI
> configuration space.
> 
> Definitely not impossible to implement, but the driver doesn't work
> as-is.

Ok.

> > We also don't seem to need any MBUS window setup for the I/O and
> > memory spaces, which greatly simplifies the driver compared to the
> > pci-mvebu one, it would be a fairly straightforward implementation
> > based on pci-host-generic.c (which unfortunately just got way
> > more complicated and might need to go on a diet).
> 
> MBus windows are needed. See:
> 
>         mvebu_mbus_add_window_remap_by_id(ORION_MBUS_PCI_IO_TARGET,
>                                           ORION_MBUS_PCI_IO_ATTR,
>                                           ORION5X_PCI_IO_PHYS_BASE,
>                                           ORION5X_PCI_IO_SIZE,
>                                           ORION5X_PCI_IO_BUS_BASE);
>         mvebu_mbus_add_window_by_id(ORION_MBUS_PCI_MEM_TARGET,
>                                     ORION_MBUS_PCI_MEM_ATTR,
>                                     ORION5X_PCI_MEM_PHYS_BASE,
>                                     ORION5X_PCI_MEM_SIZE);
> 
> in orion5x_setup_wins().

Ok, I was just looking at the wrong file, as they are set up from
common.c, not pci.c.

> Note that we already have some Orion5x converted to DT, and that use
> PCI: board-rd88f5182.c is an example. So we could very well take Jamie
> patches as-is, and move later to a DT-representation for PCI/PCIe.

Ah, I thought all the DT users were moved to mach-mvebu. I agree
this new patch isn't introducing anything we don't already have then,
so we can just take it, but the conversion will not be nice when
we do that.

I was also hoping that we could get to the point where pci_common_init()
is only used for legacy machines without DT and without multiplatform,
it seems I missed a couple of users here.

	Arnd
