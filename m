From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] sh_eth: use random MAC address if no valid one
 supplied
Date: Tue, 30 Apr 2013 11:01:49 +0900
Message-ID: <20130430020148.GH22535@verge.net.au>
References: <201304292349.43251.sergei.shtylyov@cogentembedded.com>
 <6838772.e2fl6QhECK@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6838772.e2fl6QhECK@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 29, 2013 at 10:39:17PM +0200, Laurent Pinchart wrote:
> On Monday 29 April 2013 23:49:42 Sergei Shtylyov wrote:
> > On Renesas R-Car based development boards, although a MAC address is printed
> > on all the Ethernet port labels, U-Boot  doesn't write a valid MAC address 
> > to the Ether MAHR/MALR registers (there's no storage provided for the Ether
> > MAC address either), so we have to resort to using a random MAC address...
> > 
> > Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Acked-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

FYI, I believe that the lager board, which is an R-Car based development
board (AFAIK) does not suffer from this problem.

> > ---
> > This patch is against the 'net-next.git' repository.
> > 
> > Changes since the original posting:
> > - don't break the message string into 2 lines.
> > 
> >  drivers/net/ethernet/renesas/sh_eth.c |    5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
> > ===================================================================
> > --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> > +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -2735,6 +2735,11 @@ static int sh_eth_drv_probe(struct platf
> > 
> >  	/* read and set MAC address */
> >  	read_mac_address(ndev, pd->mac_addr);
> > +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> > +		dev_warn(&pdev->dev,
> > +			 "no valid MAC address supplied, using a random one.\n");
> > +		eth_hw_addr_random(ndev);
> > +	}
> > 
> >  	/* ioremap the TSU registers */
> >  	if (mdp->cd->tsu) {
> 
> -- 
> Regards,
> 
> Laurent Pinchart
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
