From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Fri, 9 Nov 2007 16:25:07 +0300
Message-ID: <20071109132507.GA21232@localhost.localdomain>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com> <20071108141611.GA5770@localhost.localdomain> <20071108121508.39a65c33.kim.phillips@freescale.com> <20071108183952.GA18117@localhost.localdomain> <20071108131135.e16a2f9a.kim.phillips@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, paulus@samba.org, jgarzik@pobox.com
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:56124 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753041AbXKIN1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 08:27:38 -0500
Content-Disposition: inline
In-Reply-To: <20071108131135.e16a2f9a.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 01:11:35PM -0600, Kim Phillips wrote:
[...]
> right, but whether it does or not doesn't affect your failure outcome
> either I'm assuming.
> 
> > > If it's something like 0x03, the u-boot patch will probably look like:
> > > 
> > > if ((bcsr[12] == 0x10) &&
> > >     (immr->sysconf.spridr == SPR_8360_REV21 ||
> > >      immr->sysconf.spridr == SPR_8360E_REV21))
> > > 	/* if phy-connection-type is "rgmii-id", set it to "rgmii-rxid" */
> > >         ...
> > > 
> > > but these linux patches would remain the same (the clk and data delay
> > > settings for the UCC's are still valid; it's just the PHY config
> > > that is triggering your problem from what I can tell).
> > 
> > Yup, most likely this is not UCC specific, but PHY. For some reason
> > delays making harm here...

And today I was unable to reproduce yesterday's behaviour. Your
patches works fine, with sixth patch and without it. With -rxid
and with just -id.

Though, after few resets I hit on that:

- - - -
U-Boot 1.3.0-rc3-g281df457-dirty (Nov  6 2007 - 18:19:35) MPC83XX

Reset Status: External/Internal Soft, External/Internal Hard

CPU:   e300c1, MPC8360E, Rev: 21 at 528 MHz, CSB:  264 MHz
Board: Freescale MPC8360EMDS
I2C:   ready
DRAM:  256 MB (DDR2, 64-bit, ECC on)
SDRAM: 64 MB (local bus)
FLASH: 32 MB
In:    serial
Out:   serial
Err:   serial
Net:   UEC: PHY is Marvell 88E11x1 (1410cc2)
FSL UEC0: Full Duplex
switching to rgmii 100
FSL UEC0: Speed 100BT
FSL UEC0: Link is up
read wrong value : mii_id 1,mii_reg 2, base e0103120
read wrong value : mii_id 1,mii_reg 3, base e0103120
UEC: PHY is Generic MII (ffffffff)
read wrong value : mii_id 1,mii_reg 1, base e0103120
read wrong value : mii_id 1,mii_reg 1, base e0103120
read wrong value : mii_id 1,mii_reg 5, base e0103120
FSL UEC1: Full Duplex
switching to rgmii 100
FSL UEC1: Speed 100BT
FSL UEC1: Link is up
FSL UEC0, FSL UEC1
- - - -

And UCC1 does not work at all. After another reset that message
disappears and it does work again.


So, I think hardware is tricking me in various ways, not your
patches fault.

:-(

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
