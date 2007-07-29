From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH] sb1000: prevent a potential NULL pointer dereference in
 sb1000_dev_ioctl()
Date: Sun, 29 Jul 2007 11:34:47 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0707291106500.30928@enigma.security.iitk.ac.in>
References: <200707290002.42722.jesper.juhl@gmail.com>
 <20070729043707.GA8343@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Jesper Juhl <jesper.juhl@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Hirsch <shirsch@adelphia.net>,
	"David S. Miller" <davem@davemloft.net>,
	Franco Venturi <fventuri@mediaone.net>
To: Domen Puncer <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35349 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559AbXG2Fwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 01:52:33 -0400
In-Reply-To: <20070729043707.GA8343@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 29 Jul 2007, Domen Puncer wrote:

> On 29/07/07 00:02 +0200, Jesper Juhl wrote:
> > Hi,
> > 
> > Here's a small patch, prompted by a find by the Coverity checker, 
> > that removes a potential NULL pointer dereference from 
> > drivers/net/sb1000.c::sb1000_dev_ioctl().
> > The checker spotted that we do a NULL test of 'dev', yet we 
> > dereference the pointer prior to that check.
> > This patch simply moves the dereference after the NULL test.
> 
> But... it can't be called without a valid 'dev', no?
> A quick 'grep do_ioctl net/' confirms that all calls are in
> the form of 'dev->do_ioctl(dev, ...'.

Yup, I think so too ...


> > @@ -991,11 +991,13 @@ static int sb1000_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> >  	short PID[4];
> >  	int ioaddr[2], status, frequency;
> >  	unsigned int stats[5];
> > -	struct sb1000_private *lp = netdev_priv(dev);
> > +	struct sb1000_private *lp;
> >  
> >  	if (!(dev && dev->flags & IFF_UP))
> >  		return -ENODEV;

I think we could get rid of the !dev check itself. Actually, the IFF_UP
check /also/ looks suspect to me for two reasons: (1) I remember Stephen
Hemminger once telling me dev->flags is legacy and unsafe, and one of
the netif_xxx() functions be used instead, and, (2) I wonder if we really
require the interface to be up and *running* when we do this ioctl.


Satyam
