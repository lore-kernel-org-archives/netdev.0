From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] NAPI as kobject proposal
Date: Wed, 3 Feb 2010 13:41:56 -0800
Message-ID: <20100203134156.086e3e70@nehalam>
References: <20100129101839.36944ba5@nehalam>
	<1265232216.2116.46.camel@achroite.uk.solarflarecom.com>
	<20100203212641.GB30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49149 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932777Ab0BCVmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 16:42:09 -0500
In-Reply-To: <20100203212641.GB30031@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Feb 2010 21:26:41 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Feb 03, 2010 at 09:23:36PM +0000, Ben Hutchings wrote:
> > On Fri, 2010-01-29 at 10:18 -0800, Stephen Hemminger wrote:
> > > The NAPI interface structure in current kernels is managed by the driver.
> > > As part of receive packet steering there is a requirement to add an
> > > additional parameter to this for the CPU map. And this map needs to
> > > have an API to set it.
> > > 
> > > The right way to do this in the kernel model is to make NAPI into
> > > a kobject and associate it back with the network device (parent).
> > > This isn't wildly difficult but does change some of the API for
> > > network device drivers because:
> > >   1. They need to handle another possible error on setup
> > >   2. NAPI object needs to be dynamically allocated
> > >      separately (not as part of netdev_priv)
> > >   3. Driver should pass index that can be uses as part of
> > >      name (easier than scanning)
> 
> 4. Lifetime rules become oh-so-fscking-interesting?

My original proposal doesn't go far enough. I am doing a bigger
version that changes API to:
   napi_alloc / napi_release

The lifetime problem isn't that bad because the napi is a child
of network device object.  Make it a child bus object is a bigger
problem because then network device can come and go.

-- 
