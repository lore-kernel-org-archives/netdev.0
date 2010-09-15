From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [vendor-sec] [PATCH] wireless: fix 64K kernel heap content
 leak via ioctl
Date: Thu, 16 Sep 2010 01:11:07 +0200
Message-ID: <1284592267.3707.7.camel@jlt3.sipsolutions.net>
References: <20100827210240.GC4703@outflux.net>
	 <20100915224836.GF19835@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100915224836.GF19835-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 15:48 -0700, Greg KH wrote:
> On Fri, Aug 27, 2010 at 02:02:41PM -0700, Kees Cook wrote:
> > This problem was originally tracked down by Brad Spengler.
> > 
> > When calling wireless ioctls, if a driver does not correctly
> > validate/shrink iwp->length, the resulting copy_to_user can leak up to
> > 64K of kernel heap contents.
> > 
> > It seems that this is triggerable[1] in 2.6.32 at least on ath5k, but
> > I was not able to track down how. The twisty maze of ioctl handlers
> > stumped me. :) Other drivers I checked did not appear to have any problems,
> > but the potential remains. I'm not sure if this patch is the right approach;
> > it was fixed differently[2] in grsecurity.
> > 
> > [1] http://forums.grsecurity.net/viewtopic.php?f=3&t=2290&start=0
> > [2] http://grsecurity.net/~spender/wireless-infoleak-fix2.patch
> 
> Is this fixed differently upstream in the kernel with commit id
> 42da2f948d949efd0111309f5827bf0298bcc9a4?

Yes, that's the fix for this.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
