From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Fri, 12 Oct 2012 10:31:31 -0400
Message-ID: <20121012143131.GP12330@titan.lakedaemon.net>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20121011212629.GA14171@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>,
	Rami Rosen <rosenr@marvell.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:35627 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422686Ab2JLObl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 10:31:41 -0400
Content-Disposition: inline
In-Reply-To: <20121011212629.GA14171@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 11, 2012 at 11:26:29PM +0200, Francois Romieu wrote:
> Thomas Petazzoni <thomas.petazzoni@free-electrons.com> :
> [...]
> > diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> > new file mode 100644
> > index 0000000..4f7fe08
> > --- /dev/null
> > +++ b/drivers/net/ethernet/marvell/mvneta.c
> [...]
> > +static void mvneta_rxq_desc_num_update(struct mvneta_port *pp,
> > +				       struct mvneta_rx_queue *rxq,
> > +				       int rx_done, int rx_filled)
> > +{
> > +	u32 val;
> > +
> > +	if ((rx_done <= 0xff) && (rx_filled <= 0xff)) {
> > +		val = rx_done |
> > +		  (rx_filled << MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT);
> > +		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id), val);
> > +		return;
> > +	}
> > +
> > +	/* Only 255 descriptors can be added at once */
> > +	while ((rx_done > 0) || (rx_filled > 0)) {
> > +		if (rx_done <= 0xff) {
> > +			val = rx_done;
> > +			rx_done = 0;
> > +		} else {
> > +			val = 0xff;
> > +			rx_done -= 0xff;
> > +		}
> > +		if (rx_filled <= 0xff) {
> > +			val |= rx_filled
> > +				<< MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT;
> 
> 			val |= rx_filled << MVNETA_RXQ_ADD_NON_OCCUPIED_SHIFT;

I agree with Francois on most of these.  I prefer readability over hard
80 column limits.  Although, 80 columns is still sound guidance.  For
example, a majority of the broken lines are due to long macro and
constant names.  I did a 'git grep NETA' and didn't see anything
alarming.  So, above could become

			val |= rx_filled << NETA_RXQ_ADD_NONOCC_SHIFT;

thx,

Jason.
