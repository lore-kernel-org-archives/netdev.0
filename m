From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [Nios2-dev] [PATCH] Altera TSE: Add missing phydev
Date: Thu, 25 Dec 2014 15:55:21 +0100
Message-ID: <20141225145521.GQ16916@distanz.ch>
References: <BLU436-SMTP58313D55680097A2C4AAA0B6560@phx.gbl>
 <20141225125239.GP16916@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nios2-dev <nios2-dev@lists.rocketboards.org>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	netdev@vger.kernel.org
To: Kostya Belezko <bkostya@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:54629 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbaLYOzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Dec 2014 09:55:25 -0500
Content-Disposition: inline
In-Reply-To: <20141225125239.GP16916@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-25 at 13:52:39 +0100, Tobias Klauser <tklauser@distanz.ch> wrote:
> On 2014-12-22 at 23:37:19 +0100, Kostya Belezko <bkostya@hotmail.com> wrote:
> > Altera network device doesn't come up after
> > 
> > ifconfig eth0 down
> > ifconfig eth0 up
> > 
> > The reason behind is clearing priv->phydev during tse_shutdown().
> > The phydev is not restored back at tse_open().
> > 
> > Signed-off-by: Kostya Belezko <bkostya@hotmail.com>
> 
> Please Cc: netdev@vger.kernel.org for network driver patches.
> 
> > ---
> >  drivers/net/ethernet/altera/altera_tse_main.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
> > index 4efc435..361bf35 100644
> > --- a/drivers/net/ethernet/altera/altera_tse_main.c
> > +++ b/drivers/net/ethernet/altera/altera_tse_main.c
> > @@ -1150,6 +1150,9 @@ static int tse_open(struct net_device *dev)
> >  
> >  	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
> >  
> > +	if (!priv->phydev)
> > +		init_phy(dev);
> 
> That way the PHY will be initialized twice on first start.

It actually won't. Sorry, I didn't read careful enough.

Still, the solution suggested below is preferable IMO and this is also
what other ethernet drivers are doing (at least those I checked).

> IMO the proper solution would be to disconnect and NULL the phydev in
> altera_tse_remove, not in tse_shutdown. There, only phy_stop should be
> called.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
