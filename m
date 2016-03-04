From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next V2 06/16] net: fec: don't clear all rx queue
 bits when just one is being checked
Date: Fri, 4 Mar 2016 16:38:54 +0000
Message-ID: <20160304163854.GD19428@n2100.arm.linux.org.uk>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-7-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18550FD3A944783B88BEDB64FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <56D9B54B.8020309@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:40467 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216AbcCDQjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:39:10 -0500
Content-Disposition: inline
In-Reply-To: <56D9B54B.8020309@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 09:18:19AM -0700, Troy Kisky wrote:
> On 3/4/2016 2:11 AM, Fugang Duan wrote:
> > From: Troy Kisky <troy.kisky@boundarydevices.com>Sent: Thursday, February 25, 2016 8:37 AM
> >> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> >> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> >> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> >> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> >> johannes@sipsolutions.net; stillcompiling@gmail.com;
> >> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> >> <troy.kisky@boundarydevices.com>
> >> Subject: [PATCH net-next V2 06/16] net: fec: don't clear all rx queue bits when
> >> just one is being checked
> >>
> >> FEC_ENET_RXF is 3 separate bits, we only check one queue at a time. So, when
> >> the last queue is being checked, it is bad to remove the interrupt on the 1st
> >> queue.
> >>
> >> Also, since this is now done in the napi routine and not the interrupt, it is not
> >> needed.
> >>
> >> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> >> ---
> >>  drivers/net/ethernet/freescale/fec_main.c | 2 --
> >>  1 file changed, 2 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> >> b/drivers/net/ethernet/freescale/fec_main.c
> >> index 610cf6c..791f385 100644
> >> --- a/drivers/net/ethernet/freescale/fec_main.c
> >> +++ b/drivers/net/ethernet/freescale/fec_main.c
> >> @@ -1338,8 +1338,6 @@ static int fec_rxq(struct net_device *ndev, struct
> >> fec_enet_private *fep,
> >>  			break;
> >>  		pkt_received++;
> >>
> >> -		writel(FEC_ENET_RXF, fep->hwp + FEC_IEVENT);
> >> -
> > 
> > We should clear the related rx queue ievent, not remove the code.
> > Pls see commit: db3421c114cf that was submitted by Russell King.
> > 
> > No ack the patch.
> 
> 
> This is now done in patch #4 "net: fec: reduce interrupts" and you could argue
> that it should be squashed into that patch. But I like separating changes
> as much as possible.
> 
> 
> Russell, this patch and patch #4 will likely need your ack before it will be applied.
> Can you take a look please?

I stopped caring about the FEC ethernet driver about 18 months ago,
after I ended up dropping a significant pile of fixes on the floor
through the huge number of conflicts and the shere effort of
constantly trying to move them forward.

My patch series tend to be large because I put concentrated effort
into something for a month, which then gives a problem if conflicts
come up later and the series has to be effectively rewritten from
scratch.  It was after the second or third time of facing an almost
total rewrite that happened that I just gave up.

I've toyed with the idea of forking the driver, but I wouldn't have
time to maintain such a thing.  So, right now I just put up with all
the bad quirks, and reset/power cycle the boards when things go wrong.
Right now, I just disable runtime PM support on the FEC to get
stability here. :)

Sorry, but I can't be of more help.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
