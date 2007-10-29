From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skye/skge: sparse fix - data can't ever be bigger than
 LONG_MAX / HZ
Date: Mon, 29 Oct 2007 08:32:10 -0700
Message-ID: <20071029083210.0e2c75a0@freepuppy.rosehill>
References: <20071026221028.1873.3005.stgit@localhost.localdomain>
	<4725B05A.9050507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33386 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424AbXJ2Pct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 11:32:49 -0400
In-Reply-To: <4725B05A.9050507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007 06:05:14 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Auke Kok wrote:
> > Trivial replacement - use INT_MAX instead here.
> > 
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> > Cc: shemminger@linux-foundation.org
> > ---
> > 
> >  drivers/net/sk98lin/skethtool.c |    4 ++--
> >  drivers/net/skge.c              |    8 ++++----
> >  drivers/net/sky2.c              |    8 ++++----
> >  3 files changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
> > index 5a6da89..4549b97 100644
> > --- a/drivers/net/sk98lin/skethtool.c
> > +++ b/drivers/net/sk98lin/skethtool.c
> > @@ -430,8 +430,8 @@ static int locateDevice(struct net_device *dev, u32 data)
> >  	DEV_NET *pNet = netdev_priv(dev);
> >  	SK_AC *pAC = pNet->pAC;
> >  
> > -	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
> > -		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
> > +	if (!data)
> > +		data = INT_MAX;
> >  
> >  	/* start blinking */
> >  	pAC->LedsOn = 0;
> > diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> > index b9961dc..696a79e 100644
> > --- a/drivers/net/skge.c
> > +++ b/drivers/net/skge.c
> > @@ -783,10 +783,10 @@ static int skge_phys_id(struct net_device *dev, u32 data)
> >  	unsigned long ms;
> >  	enum led_mode mode = LED_MODE_TST;
> >  
> > -	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
> > -		ms = jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT / HZ) * 1000;
> > -	else
> > -		ms = data * 1000;
> > +	if (!data)
> > +		data = INT_MAX;
> > +
> > +	ms = data * HZ;
> >  
> >  	while (ms > 0) {
> >  		skge_led(skge, mode);
> > diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> > index c27c7d6..1381d04 100644
> > --- a/drivers/net/sky2.c
> > +++ b/drivers/net/sky2.c
> > @@ -3336,10 +3336,10 @@ static int sky2_phys_id(struct net_device *dev, u32 data)
> >  	int interrupted;
> >  	int onoff = 1;
> >  
> > -	if (!data || data > (u32) (MAX_SCHEDULE_TIMEOUT / HZ))
> > -		ms = jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT);
> > -	else
> > -		ms = data * 1000;
> > +	if (!data)
> > +		data = INT_MAX:
> > +
> > +	ms = data * HZ;
> 
> ditto comments in previous email...

Since these all use ethtool, shouldn't the checks be put into ethtool_phys_id
rather than having the driver check?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
