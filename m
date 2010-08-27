From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Fri, 27 Aug 2010 14:53:16 -0700
Message-ID: <20100827215316.GA32405@bougret.hpl.hp.com>
References: <20100827210240.GC4703@outflux.net> <20100827212254.GB32275@bougret.hpl.hp.com> <20100827214357.GE4703@outflux.net>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100827214357.GE4703-oSa+0FWJbaXR7s880joybQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 02:43:57PM -0700, Kees Cook wrote:
> Hi Jean,
> 
> The comment should probably be clarified -- it's the caller's iwp->length
> that may be causing problems

	Ha ! I see. It would be for regular iwpoint queries, not for
extended NOMAX queries (scan is a extended NOMAX query).
	Note that I don't like the idea of reducing the mallocated
size, especially with regular queries, as I know that some driver may
expect a fixed size in extra and may memcpy to it without double
checking.

> Regardless, the above patch would appear to limit the copy_to_user
> to only the kzalloced region.

	I'm glad you like it.

> Thanks!
> 
> -Kees

	Regards,

	Jean
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
