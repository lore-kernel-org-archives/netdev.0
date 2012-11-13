From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tilegx: request_irq with a non-null device name
Date: Tue, 13 Nov 2012 13:50:16 -0800
Message-ID: <20121113135016.229e2571@nehalam.linuxnetplumber.net>
References: <1352840300-27814-1-git-send-email-simon.marchi@polymtl.ca>
	<50A2BD87.3060202@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Marchi <simon.marchi@polymtl.ca>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A2BD87.3060202@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2012 16:37:11 -0500
Chris Metcalf <cmetcalf@tilera.com> wrote:

> On 11/13/2012 3:58 PM, Simon Marchi wrote:
> > This patch simply makes the tilegx net driver call request_irq with a
> > non-null name. It makes the output in /proc/interrupts more obvious, but
> > also helps tools that don't expect to find null there.
> >
> > Signed-off-by: Simon Marchi <simon.marchi@polymtl.ca>
> > ---
> >  drivers/net/ethernet/tile/tilegx.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
> > index 4e98100..66e025a 100644
> > --- a/drivers/net/ethernet/tile/tilegx.c
> > +++ b/drivers/net/ethernet/tile/tilegx.c
> > @@ -917,7 +917,7 @@ static int tile_net_setup_interrupts(struct net_device *dev)
> >  	ingress_irq = rc;
> >  	tile_irq_activate(ingress_irq, TILE_IRQ_PERCPU);
> >  	rc = request_irq(ingress_irq, tile_net_handle_ingress_irq,
> > -			 0, NULL, NULL);
> > +			 0, "tile_net", NULL);
> 
> Good catch.  If you can change it to dev->name instead of "tile_net", feel
> free to add my:
> 
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> 

It really should be using dev->name since that helps out some
applications like irqbalance that read /proc/interrupts
