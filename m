From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next-2.6 16/17] tg3: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 14:44:16 -0700
Message-ID: <20100927214416.GA32384@mcarlson.broadcom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
 <1285612357.2263.319.camel@achroite.uk.solarflarecom.com>
 <20100927214107.GA32336@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3406 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab0I0VoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 17:44:24 -0400
In-Reply-To: <20100927214107.GA32336@mcarlson.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 02:41:07PM -0700, Matt Carlson wrote:
> On Mon, Sep 27, 2010 at 11:32:37AM -0700, Ben Hutchings wrote:
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > This *always* sets real_num_tx_queues to 1, so this could be improved.
> > For now, do a simple conversion.
> > 
> > Ben.
> > 
> >  drivers/net/tg3.c |    8 ++++++--
> >  1 files changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index fdb438d..ca41140 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -8821,7 +8821,11 @@ static bool tg3_enable_msix(struct tg3 *tp)
> >  	for (i = 0; i < tp->irq_max; i++)
> >  		tp->napi[i].irq_vec = msix_ent[i].vector;
> >  
> > -	tp->dev->real_num_tx_queues = 1;
> > +	netif_set_real_num_tx_queues(tp->dev, 1);
> > +	if (netif_set_real_num_rx_queues(tp->dev, tp->irq_cnt)) {
> 
> This should be tp->irq_cnt - 1, not tp->irq_cnt.  The first MSI-X vector
> only handles link interrupts and device errors.

I need to correct myself.  If the irq_cnt > 1, then it needs to be
tp->irq_cnt - 1.  If the irq_cnt == 1, then it should be 1.

> > +		pci_disable_msix(tp->pdev);
> > +		return false;
> > +	}
> >  	if (tp->irq_cnt > 1)
> >  		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
> >
> > @@ -8856,7 +8860,7 @@ defcfg:
> >  	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
> >  		tp->irq_cnt = 1;
> >  		tp->napi[0].irq_vec = tp->pdev->irq;
> > -		tp->dev->real_num_tx_queues = 1;
> > +		netif_set_real_num_tx_queues(tp->dev, 1);
> >  	}
> >  }
> >  
> > -- 
> > 1.7.2.1
> > 
> > 
> > 
> > -- 
> > Ben Hutchings, Senior Software Engineer, Solarflare Communications
> > Not speaking for my employer; that's the marketing department's job.
> > They asked us to note that Solarflare product names are trademarked.
> > 
> > 
> 

