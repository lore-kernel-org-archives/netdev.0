From: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] wireless extensions: fix kernel heap content leak
Date: Mon, 30 Aug 2010 11:03:03 -0700
Message-ID: <20100830180302.GM4703@outflux.net>
References: <20100827210240.GC4703@outflux.net>
 <20100827212254.GB32275@bougret.hpl.hp.com>
 <1283158058.3691.10.camel@jlt3.sipsolutions.net>
 <1283158704.3691.11.camel@jlt3.sipsolutions.net>
 <1283162341.3691.45.camel@jlt3.sipsolutions.net>
 <1283163894.3691.48.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1283163894.3691.48.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

On Mon, Aug 30, 2010 at 12:24:54PM +0200, Johannes Berg wrote:
> --- wireless-testing.orig/net/wireless/wext-compat.c	2010-08-30 12:04:57.000000000 +0200
> +++ wireless-testing/net/wireless/wext-compat.c	2010-08-30 12:11:32.000000000 +0200
> @@ -1420,6 +1420,9 @@ int cfg80211_wext_giwessid(struct net_de
>  {
>  	struct wireless_dev *wdev = dev->ieee80211_ptr;
>  
> +	data->flags = 0;
> +	data->length = 0;
> +
>  	switch (wdev->iftype) {
>  	case NL80211_IFTYPE_ADHOC:
>  		return cfg80211_ibss_wext_giwessid(dev, info, data, ssid);

Thanks for all your work on this! Were you able to trigger the leak
through cfg80211? If so, then this will need a CVE assigned and sent to
stable too, I think.

-Kees

-- 
Kees Cook
Ubuntu Security Team
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
