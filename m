From: Greg KH <greg@kroah.com>
Subject: Re: [vendor-sec] [PATCH] wireless: fix 64K kernel heap content
 leak via ioctl
Date: Wed, 15 Sep 2010 16:28:04 -0700
Message-ID: <20100915232804.GB25877@kroah.com>
References: <20100827210240.GC4703@outflux.net>
 <20100915224836.GF19835@kroah.com>
 <1284592267.3707.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, Jean Tourrilhes <jt@hpl.hp.com>,
	Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:34816 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303Ab0IOX2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 19:28:22 -0400
Content-Disposition: inline
In-Reply-To: <1284592267.3707.7.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 16, 2010 at 01:11:07AM +0200, Johannes Berg wrote:
> On Wed, 2010-09-15 at 15:48 -0700, Greg KH wrote:
> > On Fri, Aug 27, 2010 at 02:02:41PM -0700, Kees Cook wrote:
> > > This problem was originally tracked down by Brad Spengler.
> > > 
> > > When calling wireless ioctls, if a driver does not correctly
> > > validate/shrink iwp->length, the resulting copy_to_user can leak up to
> > > 64K of kernel heap contents.
> > > 
> > > It seems that this is triggerable[1] in 2.6.32 at least on ath5k, but
> > > I was not able to track down how. The twisty maze of ioctl handlers
> > > stumped me. :) Other drivers I checked did not appear to have any problems,
> > > but the potential remains. I'm not sure if this patch is the right approach;
> > > it was fixed differently[2] in grsecurity.
> > > 
> > > [1] http://forums.grsecurity.net/viewtopic.php?f=3&t=2290&start=0
> > > [2] http://grsecurity.net/~spender/wireless-infoleak-fix2.patch
> > 
> > Is this fixed differently upstream in the kernel with commit id
> > 42da2f948d949efd0111309f5827bf0298bcc9a4?
> 
> Yes, that's the fix for this.

Wonderful, thanks for letting me know.

greg k-h
