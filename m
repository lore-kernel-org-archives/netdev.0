From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Sat, 12 Sep 2009 18:51:44 +0200
Message-ID: <200909121851.46002.mb@bu3sch.de>
References: <200909111648.50902.mb@bu3sch.de> <200909111813.35810.mb@bu3sch.de> <4AABCF28.6090505@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AABCF28.6090505-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 12 September 2009 18:41:12 Oliver Hartkopp wrote:
> Michael Buesch wrote:
> 
> >> As there are several users in the kernel do exact this test and call the
> >> appropriate netif_rx() function, i would suggest to create a static inline
> >> function:
> >>
> >> static inline int netif_rx_ti(struct sk_buff *skb)
> >> {
> >> 	if (in_interrupt())
> >> 		return netif_rx(skb);
> >> 	return netif_rx_ni(skb);
> >> }
> >>
> >> ('ti' for test in_interrupt())
> >>
> >> in include/linux/netdevice.h
> >>
> >> What do you think about that?
> > 
> > Yeah, I'm fine with that.
> > 
> 
> Hi Michael,
> 
> i cooked a patch that introduces netif_rx_ti() and fixes up the problems in
> mac80211 and the CAN subsystem.
> 
> Currently i'm pondering whether netif_rx_ti() is needed in all cases or if
> there are code sections that'll never be executed from irq-context.
> 
> In theses cases netif_rx_ni() should be prefered to netif_rx_ti() to prevent
> the obsolete check ...
> 
> Is there any of your changes that should better use netif_rx_ni() ?
> 
> Regards,
> Oliver
> 

Well, I'd say this check does not cost much at all.
If I were the net maintainer, I'd get rid of netif_rx_ni() _and_ netif_rx_ti() and
do the check internally in netif_rx().
But as I don't have to decide that, I just want the mac80211 issue fixed.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
