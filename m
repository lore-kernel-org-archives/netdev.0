From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 5/9] netconsole: Introduce dev_status member
Date: Wed, 4 Jul 2007 22:03:13 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707042158001.757@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704135642.GB11115@waste.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:35833 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbXGDQLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 12:11:50 -0400
In-Reply-To: <20070704135642.GB11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jul 2007, Matt Mackall wrote:
> On Wed, Jul 04, 2007 at 04:38:04PM +0530, Satyam Sharma wrote:
> > [...]
> > +/*
> > + * Why no net_dev_is_up() in netdevice.h? The kernel could lose a lot of
> > + * weight if only netdevice.h had the good sense to export such a function.
> > + * Oh well ...
> > + */
> > +static inline int net_dev_is_up(struct net_device *net_dev)
> > +{
> > +	return ((net_dev->flags & IFF_UP) == IFF_UP);
> > +}
> 
> Why editorialize? Why not just add this to netdevice.h?

Hmm, I wanted to keep all changes local to netconsole, but ...
ok, will do that.

> > +	if (nt->dev_status) {
> 
> Why not simply call net_dev_is_up?

Yes, I did consider just calling the function here instead of
introducing another member ... again, ok will do that ...

> > We then join this up with the just-introduced net_device notifier, and
> > introduce NETDEV_UP and NETDEV_DOWN notifications. By disabling the target
> > when the corresponding local interface is down, we save the overhead of
> > unnecessarily disabling interrupts and calling into the netpoll stack in
> > console->write().
> 
> Yuck. 

... so all this will go too.

Satyam
