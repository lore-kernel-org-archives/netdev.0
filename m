From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH] sb1000: prevent a potential NULL pointer dereference in
 sb1000_dev_ioctl()
Date: Mon, 30 Jul 2007 00:39:31 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0707300034460.30928@enigma.security.iitk.ac.in>
References: <200707290002.42722.jesper.juhl@gmail.com>
 <alpine.LFD.0.999.0707291106500.30928@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0707300003440.30928@enigma.security.iitk.ac.in>
 <200707292048.20531.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Domen Puncer <domen@coderock.org>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Hirsch <shirsch@adelphia.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35154 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760369AbXG2S5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 14:57:16 -0400
In-Reply-To: <200707292048.20531.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,


On Sun, 29 Jul 2007, Michael Buesch wrote:

> On Sunday 29 July 2007 20:34:46 Satyam Sharma wrote:
> > (2) !(dev->flags & IFF_UP) is bogus because the functions of this ioctl
> > can (and should) be allowed even when the interface is not up and running.
> 
> Are you _sure_? This function does poke with the device hardware.
> It might return crap or even machinecheck when not initialized.
> Hardware is probably powered down, if not IFF_UP. (I don't know if that's
> the case here, though).

IFF_UP checks if the _interface_ is up -- the hardware / card could still
be powered up, but the interface down (ifconfing eth0 down or ip link set
eth0 down).

Probably what we want here is netif_device_present()? -- I think that
should return true only when the *device* itself is up (as in powered)
but the interface itself could be down ...

Let's wait for comments from the netdev people Cc:'ed here, in that case.


> >  drivers/net/sb1000.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
> > index 1de3eec..f60fe98 100644
> > --- a/drivers/net/sb1000.c
> > +++ b/drivers/net/sb1000.c
> > @@ -993,9 +993,6 @@ static int sb1000_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> >  	unsigned int stats[5];
> >  	struct sb1000_private *lp = netdev_priv(dev);
> >  
> > -	if (!(dev && dev->flags & IFF_UP))
> > -		return -ENODEV;
> > -


Satyam
