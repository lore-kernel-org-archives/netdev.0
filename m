From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: FEC driver: rcv is not +last
Date: Thu, 8 Apr 2010 18:05:13 +0200
Message-ID: <20100408160513.GN3688@pengutronix.de>
References: <20100408104033.GI3787@darwin> <20100408132033.GJ3688@pengutronix.de> <20100408145324.GH29538@darwin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Matthias Kaehlcke <matthias@kaehlcke.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48397 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932684Ab0DHQFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 12:05:15 -0400
Content-Disposition: inline
In-Reply-To: <20100408145324.GH29538@darwin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 04:53:24PM +0200, Matthias Kaehlcke wrote:
> El Thu, Apr 08, 2010 at 03:20:33PM +0200 Sascha Hauer ha dit:
> 
> > On Thu, Apr 08, 2010 at 12:40:33PM +0200, Matthias Kaehlcke wrote:
> > > hi,
> > > 
> > > i have problems with the FEC on a i.MX25 3-Stack board. the kernel is
> > > v2.6.34-rc2 plus the following patch:
> > > http://patchwork.ozlabs.org/patch/41235/
> > > 
> > > the following traces are generated at boot time:
> > > 
> > > FEC Ethernet Driver
> > > fec: PHY @ 0x1, ID 0x20005ce1 -- unknown PHY!
> > > ...
> > > eth0: config: auto-negotiation on, 100FDX, 100HDX, 10FDX, 10HDX.
> > > ...
> > > FEC ENET: rcv is not +last
> > > FEC ENET: rcv is not +last
> > > FEC ENET: rcv is not +last
> > > FEC ENET: rcv is not +last
> > > ...
> > 
> > No idea, I have never seen this message. Does the controller work
> > besides these messages?
> 
> nope
> 
> > > the PHY of the board is a DP83840, which is not supported by the
> > > driver. could this be the problem? i tried to make the kernel think
> > > the DP83840 is a DP83848, which is supported, but the behaviour is the
> > > same except the 'unknown PHY' warning.
> > 
> > This should be solved by the phylib patches recently posted for the fec
> > driver.
> 
> thanks for the pointer!
> 
> i just applied the patch. it actually makes the 'unkown PHY' and even
> the 'FEC ENET: rcv is not +last' messages disappear, but networking
> still doesn't work

AFAIK there is nothing special about the fec in the i.MX25 except the
RMII mode, so just some more things you can check:

- Does it work in the bootloader? (Are you using barebox?)
- Are packets transmitted/received at all?
- Have you configured the MAC address? currently the fec driver relies
  on finding a valid MAC address in the FEC_ADDR_LOW/FEC_ADDR_HIGH
  registers

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
