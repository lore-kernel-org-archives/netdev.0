From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood
 SoCs
Date: Thu, 23 May 2013 11:53:57 -0600
Message-ID: <20130523175357.GB2821@obsidianresearch.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130522201607.GA18823@obsidianresearch.com>
 <20130523160111.GP31290@titan.lakedaemon.net>
 <20130523171112.GB31281@obsidianresearch.com>
 <20130523172339.GQ31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130523172339.GQ31290@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 01:23:39PM -0400, Jason Cooper wrote:

> Shouldn't it rather be
> 
> 	compatible = "marvell,kirkwood-eth", "marvell,orion-eth";

Not sure about orion-eth?
 
> I'm inclined to go with of_machine_is_compatible() since the only
> concrete difference we know is that the tweak is needed on kirkwood and
> nowhere else.

But there is a larger problem here then just this one bit.

The PSC1 register must be set properly for the board layout, and today
we rely on the bootloader to set it. In fact, even with Sebastian's
change the ethernet port won't work without bootloader
intervention. The PortReset bit should also be cleared by the driver
(and it is only present on some variants of this IP block,
apparently).

We know that some Marvell SOC's wack the ethernet registers when they
clock gate, and the flip of Clk125Bypass is another symptom of this
general problem.

So, long term, the PSC1 must be fully set by the driver, based on DT
information describing the board (eg RGMII/MII/1000Base-X [SFP] Phy
type), and the layout of this register seems to vary on a SOC by SOC
basis.

Thus, I think it is appropriate to call this variant of the eth IP
'marvell,kirkwood-eth' which indicates that the register block follows
the kirkwood manual and the PSC1 register specifically has the
kirkwood layout.

The question is what other Marvell SOCs have the same PSC1 layout as
kirkwood?

Jason
