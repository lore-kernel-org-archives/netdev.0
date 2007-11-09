From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Fri, 9 Nov 2007 14:16:36 -0600
Message-ID: <20071109141636.b0f11c91.kim.phillips@freescale.com>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
	<20071108141611.GA5770@localhost.localdomain>
	<20071108121508.39a65c33.kim.phillips@freescale.com>
	<20071108183952.GA18117@localhost.localdomain>
	<20071108131135.e16a2f9a.kim.phillips@freescale.com>
	<20071109132507.GA21232@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, paulus@samba.org,
	Li Yang <leoli@freescale.com>, jgarzik@pobox.com
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071109132507.GA21232@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Nov 2007 16:25:07 +0300
Anton Vorontsov <avorontsov@ru.mvista.com> wrote:

> On Thu, Nov 08, 2007 at 01:11:35PM -0600, Kim Phillips wrote:
> [...]
> > right, but whether it does or not doesn't affect your failure outcome
> > either I'm assuming.
> > 
> > > > If it's something like 0x03, the u-boot patch will probably look like:
> > > > 
> > > > if ((bcsr[12] == 0x10) &&
> > > >     (immr->sysconf.spridr == SPR_8360_REV21 ||
> > > >      immr->sysconf.spridr == SPR_8360E_REV21))
> > > > 	/* if phy-connection-type is "rgmii-id", set it to "rgmii-rxid" */
> > > >         ...
> > > > 
> > > > but these linux patches would remain the same (the clk and data delay
> > > > settings for the UCC's are still valid; it's just the PHY config
> > > > that is triggering your problem from what I can tell).
> > > 
> > > Yup, most likely this is not UCC specific, but PHY. For some reason
> > > delays making harm here...
> 
> And today I was unable to reproduce yesterday's behaviour. Your
> patches works fine, with sixth patch and without it. With -rxid
> and with just -id.

excellent.  btw, you should be paying a 50% packet loss price by not
going with the -rxid.  ping your board with '-q -s 1400 -i 0.01 -c 100'
to notice the difference.

> 
> Though, after few resets I hit on that:
> 
> - - - -
> U-Boot 1.3.0-rc3-g281df457-dirty (Nov  6 2007 - 18:19:35) MPC83XX
> 
> Reset Status: External/Internal Soft, External/Internal Hard
> 
> CPU:   e300c1, MPC8360E, Rev: 21 at 528 MHz, CSB:  264 MHz
> Board: Freescale MPC8360EMDS
> I2C:   ready
> DRAM:  256 MB (DDR2, 64-bit, ECC on)
> SDRAM: 64 MB (local bus)
> FLASH: 32 MB
> In:    serial
> Out:   serial
> Err:   serial
> Net:   UEC: PHY is Marvell 88E11x1 (1410cc2)
> FSL UEC0: Full Duplex
> switching to rgmii 100
> FSL UEC0: Speed 100BT
> FSL UEC0: Link is up
> read wrong value : mii_id 1,mii_reg 2, base e0103120
> read wrong value : mii_id 1,mii_reg 3, base e0103120
> UEC: PHY is Generic MII (ffffffff)
> read wrong value : mii_id 1,mii_reg 1, base e0103120
> read wrong value : mii_id 1,mii_reg 1, base e0103120
> read wrong value : mii_id 1,mii_reg 5, base e0103120
> FSL UEC1: Full Duplex
> switching to rgmii 100
> FSL UEC1: Speed 100BT
> FSL UEC1: Link is up
> FSL UEC0, FSL UEC1
> - - - -
> 
> And UCC1 does not work at all. After another reset that message
> disappears and it does work again.
> 
the RGMII bcsr settings survive soft-resets, which confuse u-boot since
it uses GMII mode.

Kim
