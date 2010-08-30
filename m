From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Mon, 30 Aug 2010 19:50:02 +0200
Message-ID: <1283190602.3694.3.camel@jlt3.sipsolutions.net>
References: <20100827210240.GC4703@outflux.net>
	 <20100827212254.GB32275@bougret.hpl.hp.com>
	 <1283158058.3691.10.camel@jlt3.sipsolutions.net>
	 <1283158704.3691.11.camel@jlt3.sipsolutions.net>
	 <1283162341.3691.45.camel@jlt3.sipsolutions.net>
	 <20100830174018.GA3639@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100830174018.GA3639-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-30 at 10:40 -0700, Jean Tourrilhes wrote:

>         Ha ! I see. It would be for regular iwpoint queries, not for
> extended NOMAX queries (scan is a extended NOMAX query).

Yeah, that took a while to sink in here too ..

> 	I actually like your patch better than mine, it's closer to
> the original intent of the API. Go for it ;-)

> 	Thanks a lot for the second pair of eyes.

And thank you for looking over my patch. I guess the real bug is still
in cfg80211 there.

Initially I considered setting iwp->length to zero, rather than
max_tokens. What do you think about doing that? The reason I decided to
use max_tokens was that somebody might look at the length value to know
how much to copy (which is OK only in NOMAX queries); but that would be
a more severe driver bug ... can't really make up my mind. We just copy
back zeroes anyway.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
