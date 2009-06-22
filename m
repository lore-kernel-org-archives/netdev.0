From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Mon, 22 Jun 2009 06:56:18 -0400
Message-ID: <20090622105618.GA13043@hmsreliant.think-freely.org>
References: <20090621171141.GA2893@localhost.localdomain> <20090622054315.GA4928@ff.dom.local> <20090622085950.GA26598@ms2.inr.ac.ru> <20090622.024243.70686716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jarkao2@gmail.com, netdev@vger.kernel.org,
	mbizon@freebox.fr, dada1@cosmosbay.com, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58821 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbZFVK42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 06:56:28 -0400
Content-Disposition: inline
In-Reply-To: <20090622.024243.70686716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 02:42:43AM -0700, David Miller wrote:
> From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Date: Mon, 22 Jun 2009 12:59:50 +0400
> 
> > On Mon, Jun 22, 2009 at 05:43:15AM +0000, Jarek Poplawski wrote:
> >> Maybe it can work, but it needs a thorough checking now and adds a new
> >> code path to track later while looking for bugs. So, I wonder if it's
> >> not better to link such dsts in rt_intern_hash anyway, probably as a
> >> separate list, scanned only for expired entries.
> > 
> > Such a list already exists, it is gc list in core/dst.c.
> > 
> > The fix to the problem could be replacing rt_drop() with rt_free()
> > (adding rt_free() after the patch, which deleted rt_drop()), something like:
> > 
> > 	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> > 		/* ..... */
> > +		rt_free(rt);
> > 		goto report_and_exit;
> > 	}
> > 
> > rt_free() will put the route on that gc list and it will be releases
> > as soon as refcnt becomes 0.
> 
> That should work.
> 
> Can someone put together a formal patch and give it at least
> a quick test?
> 
Yeah, I can handle this, I've found another problem involving arp in this code
that I'm validating.  I'll roll both fixes together.

Neil

> 
