From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Thu, 1 Mar 2007 08:42:09 +0100
Message-ID: <20070301074209.GA1735@ff.dom.local>
References: <20070228012741.GA3988@bougret.hpl.hp.com> <20070228093437.GA1847@ff.dom.local> <20070228184541.GD6134@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	"David S\. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60083 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750828AbXCAHiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 02:38:25 -0500
Content-Disposition: inline
In-Reply-To: <20070228184541.GD6134@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 10:45:41AM -0800, Jean Tourrilhes wrote:
> On Wed, Feb 28, 2007 at 10:34:37AM +0100, Jarek Poplawski wrote:
> > On 28-02-2007 02:27, Jean Tourrilhes wrote:
> > > 	Hi all,
> > ...
> > > 	Patch for 2.6.20 is attached. The patch was tested on a system
> > > running the hotplug scripts, and on another system running udev.
> > > 
> > > 	Have fun...
> > > 
> > > 	Jean
> > > 
> > > Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
> > > 
> > > ---------------------------------------------------------
> > ...
> > > diff -u -p linux/net/core/net-sysfs.j1.c linux/net/core/net-sysfs.c
> > > --- linux/net/core/net-sysfs.j1.c	2007-02-27 15:01:08.000000000 -0800
> > > +++ linux/net/core/net-sysfs.c	2007-02-27 15:06:49.000000000 -0800
> > > @@ -412,6 +412,17 @@ static int netdev_uevent(struct class_de
> > >  	if ((size <= 0) || (i >= num_envp))
> > >  		return -ENOMEM;
> > >  
> > > +	/* pass ifindex to uevent.
> > > +	 * ifindex is useful as it won't change (interface name may change)
> > > +	 * and is what RtNetlink uses natively. */
> > > +	envp[i++] = buf;
> > > +	n = snprintf(buf, size, "IFINDEX=%d", dev->ifindex) + 1;
> > > +	buf += n;
> > > +	size -= n;
> > > +
> > > +	if ((size <= 0) || (i >= num_envp))
> > 
> > Btw.:
> > 1. if size == 10 and snprintf returns 9 (without NULL)
> >    then n == 10 (with NULL), so isn't it enough (here and above):
> >  
> > 	if ((size < 0) || (i >= num_envp))
> 
> 	I just cut'n'pasted the code a few line above. If the original
> code is incorrect, it need fixing. And it will need fixing in probably
> a lot of places.

I think you're kind of responsible for your part, at least.

> 
> > 2. shouldn't there be (here and above):
> >  
> > 		envp[--i] = NULL;
> > 
> 
> 	No, envp is local, so who cares.

But envp[i] isn't (at least here). So, I guess, a caller
of this function could care.

> > > + 	if ((size <= 0) || (i >= num_envp))
> > > + 		return -ENOMEM;

And one more thing (not necessarily for you):
ENOBUFS is probably more adequate here.

Cheers,
Jarek P.
