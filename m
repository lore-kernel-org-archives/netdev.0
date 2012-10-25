From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Supporting more devices with dev_alloc_name()
Date: Thu, 25 Oct 2012 11:16:44 -0700
Message-ID: <20121025111644.301dc9d8@nehalam.linuxnetplumber.net>
References: <20121025165632.GC7857@raven>
	<1351187443.6537.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50630 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758172Ab2JYSRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 14:17:32 -0400
In-Reply-To: <1351187443.6537.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Oct 2012 19:50:43 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2012-10-25 at 17:56 +0100, Tom Parkin wrote:
> > Hi list,
> > 
> > I've recently been trying to create large-scale L2TPv3 configurations
> > of up to 50,000 Ethernet pseudowires.
> > 
> > One of the limitations I've hit has been to do with dev_alloc_name().
> > By default, l2tp_eth uses "l2tpeth%d" for device names, which is
> > expanded by dev_alloc_name() into l2tpeth1, l2tpeth2, etc.  However,
> > the algorithm dev_alloc_name() uses to derive the next free number for
> > this scheme is bounded by the number of bits in a single page.  For
> > kernels/platforms with a 4kB page, this limits these "autoderived"
> > names to 32k.
> > 
> > In my testing I've been able to work around this by specifying
> > interface names during the bringup of the l2tpeth interfaces, thereby
> > bypassing dev_alloc_name() altogether.  Using this approach I am able
> > to comfortably create 50k interfaces, even on fairly modest hardware.
> > But it seems a shame to have to do this; it would be much nicer if
> > the kernel were able to autogenerate names for more devices.
> > 
> > Is this something that would be worth my working on a patch for, or
> > would the increased code complexity be too great an overhead to
> > consider for such outlandish use-cases?
> 
> This issue was raised some ago, for the dummy device
> 
> modprobe dummy numdummies=33000
> 
> I guess each format (eg eth%d) could be attached/associated to an idr,
> so that we can find the lowest available index very fast.

You could try vzalloc() instead of get_zeroed_page which would allow for
bigger bitmap.
