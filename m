From: Greg KH <greg@kroah.com>
Subject: Re: [vendor-sec] [PATCH] wireless: fix 64K kernel heap content
 leak via ioctl
Date: Wed, 15 Sep 2010 15:48:36 -0700
Message-ID: <20100915224836.GF19835@kroah.com>
References: <20100827210240.GC4703@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Joe Perches <joe@perches.com>, Jean Tourrilhes <jt@hpl.hp.com>,
	Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kees Cook <kees.cook@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100827210240.GC4703@outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 02:02:41PM -0700, Kees Cook wrote:
> This problem was originally tracked down by Brad Spengler.
> 
> When calling wireless ioctls, if a driver does not correctly
> validate/shrink iwp->length, the resulting copy_to_user can leak up to
> 64K of kernel heap contents.
> 
> It seems that this is triggerable[1] in 2.6.32 at least on ath5k, but
> I was not able to track down how. The twisty maze of ioctl handlers
> stumped me. :) Other drivers I checked did not appear to have any problems,
> but the potential remains. I'm not sure if this patch is the right approach;
> it was fixed differently[2] in grsecurity.
> 
> [1] http://forums.grsecurity.net/viewtopic.php?f=3&t=2290&start=0
> [2] http://grsecurity.net/~spender/wireless-infoleak-fix2.patch

Is this fixed differently upstream in the kernel with commit id
42da2f948d949efd0111309f5827bf0298bcc9a4?

thanks,

greg k-h
