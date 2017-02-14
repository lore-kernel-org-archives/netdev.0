From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 01/16] dt-bindings: net: update Marvell PPv2
 binding for PPv2.2 support
Date: Tue, 14 Feb 2017 15:25:03 +0100
Message-ID: <20170214152503.602878cb@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170103201842.hdg2uzzesog2jund@rob-hp-laptop>
 <20170202175650.1fc06c2d@free-electrons.com>
 <20170203164808.GD27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Rob Herring <robh@kernel.org>,
 Yehuda Yitschak <yehuday@marvell.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>, devicetree@vger.kernel.org,
 netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Nadav Haklai <nadavh@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170203164808.GD27312@n2100.armlinux.org.uk>
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

Hello,

On Fri, 3 Feb 2017 16:48:08 +0000, Russell King - ARM Linux wrote:
> On Thu, Feb 02, 2017 at 05:56:50PM +0100, Thomas Petazzoni wrote:
> > For PPv2.2, we wanted to simplify a little bit the register mappings,
> > and simply reflect the memory map of the SoC. In the SoC datasheet,
> > there are two memory areas for the networking subsystem, which are the
> > two areas reflected in:
> > 
> >         reg = <0x0 0x100000>,
> >               <0x100000 0x80000>;
> > 
> > The per-port registers are inside the second register area. But by
> > exposing the entire register area in the Device Tree binding, we allow
> > improvements in the driver that need additional registers to be made
> > without changing the Device Tree description of the device.  
> 
> Are you sure that this makes sense?  You have the serdes block at
> 0x120000-0x125fff, which sits within that range, and that needs to
> be configured for SATA and PCIe, so it's not strictly just a network
> thing.
> 
> I know from my experimentation that disabling the "serdes" by clearing
> the SD_EXTERNAL_CONFIG1_REG and SD_EXTERNAL_CONFIG0_REG for SATA
> channels prevents SATA working.

I have simply/stupidly followed the datasheet, which says:

 Packet processor:        0xf2000000, 0xf4000000 (i.e offset 0x0 in the CP)
 Networking interfaces:   0xf2100000, 0xf4100000 (i.e offset 0x100000 in the CP)
 IO Bridge Addr Decoding: 0xf2190000, 0xf4190000

And since there is no other block described, I assumed that the entire
range 0xf2000000 to 0xf2100000 was dedicated to the "Packet processor",
and that the range 0xf2100000 to 0xf2190000 was dedicated to the
"Networking interfaces" (and I realize the size is 0x90000, not
0x80000).

On the other hand, there are registers after 0x125fff that are really
networking related. For example, the driver is currently accessing
0x12a204, which is after the SERDES related registers.

I'll try to get some more information about this, but I suspect this is
one case where we don't yet fully understand how all the HW works and
what all registers are doing, so it's hard to do a perfect DT binding
from day 1.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
