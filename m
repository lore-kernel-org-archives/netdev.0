From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] net: ethernet: renesas: sh_eth: don't open code
 of_device_get_match_data()
Date: Thu, 3 Mar 2016 09:04:03 +0900
Message-ID: <20160303000403.GA23040@verge.net.au>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
 <1456850284-8336-2-git-send-email-wsa@the-dreams.de>
 <20160302012134.GB32543@verge.net.au>
 <20160302064623.GA1403@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43103 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbcCCAEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 19:04:09 -0500
Content-Disposition: inline
In-Reply-To: <20160302064623.GA1403@katana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 07:46:24AM +0100, Wolfram Sang wrote:
> On Wed, Mar 02, 2016 at 10:21:34AM +0900, Simon Horman wrote:
> > On Tue, Mar 01, 2016 at 05:37:59PM +0100, Wolfram Sang wrote:
> > > From: Wolfram Sang <wsa+renesas@sang-engineering.com>
> > > 
> > > This change will also make Coverity happy by avoiding a theoretical NULL
> > > pointer dereference; yet another reason is to use the above helper function
> > > to tighten the code and make it more readable.
> > > 
> > > Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
> > > ---
> > > 
> > > Tested on a Lager board.
> > > 
> > >  drivers/net/ethernet/renesas/sh_eth.c | 10 +++-------
> > >  1 file changed, 3 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > > index 0a150b2289146f..8b6c07fe3d407d 100644
> > > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > > @@ -3056,15 +3056,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> > >  	mdp->ether_link_active_low = pd->ether_link_active_low;
> > >  
> > >  	/* set cpu data */
> > > -	if (id) {
> > > +	if (id)
> > >  		mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
> > > -	} else	{
> > > -		const struct of_device_id *match;
> > > +	else
> > > +		mdp->cd = (struct sh_eth_cpu_data *)of_device_get_match_data(&pdev->dev);
> > 
> > Is the cast needed here? of_device_get_match_data returns void *
> 
> The compiler complains about a const mismatch without the cast. To keep
> things simple, I decided to leave the cast.

Ok, that makes sense.

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
