From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: Re: [PATCH] Revert "net: phy: turn carrier off on phy attach"
Date: Fri, 12 Feb 2016 22:07:28 +0100
Message-ID: <20160212210728.GA5454@archie.tuxnet.lan>
References: <1455300113-2335-1-git-send-email-clemens.gruber@pqgruber.com>
 <56BE2AC4.2040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pqgruber.com ([178.189.19.235]:40244 "EHLO
	mail.pqgruber.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbcBLVHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 16:07:34 -0500
Content-Disposition: inline
In-Reply-To: <56BE2AC4.2040908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Fri, Feb 12, 2016 at 10:56:04AM -0800, Florian Fainelli wrote:
> On 12/02/16 10:01, Clemens Gruber wrote:
> > Commit 113c74d83eef ("net: phy: turn carrier off on phy attach") breaks
> > the eth0 link coming up on all my i.MX6Q boards with a Marvell 88E1510.
> > If I then do a ifconfig eth0 down/up cycle I first get a MDIO read
> > timeout but then the link becomes ready and everything is back to
> > normal.
> > Without this step however, the link stays down forever, an unusually
> > high amount of phy interrupts occur (about 10000/second) and kworker/0:2
> > is constantly using over 60% of the CPU.
> > 
> > Reverting it fixes the problems with the link not coming up at boot as
> > well as the high amount of phy interrupts and kworker load in that
> > state.
> 
> You are seeing this with the FEC driver right? We probably want to
> carefully audit the driver and understand what could be going wrong, the
> initial change is correct, so there must be something else going on here.
> 

Yes, this occurs with the fec driver.

In the fec_probe function at line 3471 of
net/ethernet/freescale/fec_main.c, netif_carrier_off is called and a
comment states "Carrier starts down, phylib will bring it up".
Could this be the source of the problem, both fec and phy expecting the
other one to turn on the carrier?

If you have an idea about what could be going wrong in the fec driver,
please let me know.

Thanks,
Clemens
