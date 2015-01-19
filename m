From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 19 Jan 2015 21:34:17 +0100
Message-ID: <9314032.C8yR0htxiP@wuerfel>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <1421217254-12008-4-git-send-email-dingtianhong@huawei.com> <54BD48BF.3050707@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
To: Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54BD48BF.3050707-l3A5Bk7waGM@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 19 January 2015 19:11:11 Alexander Graf wrote:
> 
> After hammering on the box a bit again, I'm in a situation where I get 
> lots of
> 
> [302398.232603] hip04-ether e28b0000.ethernet eth0: rx drop
> [302398.377309] hip04-ether e28b0000.ethernet eth0: rx drop
> [302398.395198] hip04-ether e28b0000.ethernet eth0: rx drop
> [302398.466118] hip04-ether e28b0000.ethernet eth0: rx drop
> [302398.659009] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.053389] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.122067] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.268192] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.286081] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.594201] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.683416] hip04-ether e28b0000.ethernet eth0: rx drop
> [302399.701307] hip04-ether e28b0000.ethernet eth0: rx drop
> 
> and I really am getting a lot of drops - I can't even ping the machine 
> anymore.
> 
> However, as it is there's a good chance the machine is simply 
> unreachable because it's busy writing to the UART, and even if not all 
> useful messages indicating anything have scrolled out. I really don't 
> think you should emit any message over and over again to the user. Once 
> or twice is enough.
>
> Please make sure to rate limit it.

I would argue that packet loss is not an error condition at all
and you should not print this at netdev_err() level. You could make
this a netdev_dbg(), or just make it silent because it's already
counted in the statistics.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
