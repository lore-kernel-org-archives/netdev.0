From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: RE: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
 skbs
Date: Fri, 31 Dec 2010 11:18:15 +0100
Message-ID: <1293790695.4507.0.camel@jlt3.sipsolutions.net>
References: <9mk4bme8o97ir27xi8a9fbsd.1293750376929@email.android.com>
	 <6F5C1D715B2DA5498A628E6B9C124F04019BF36ABD@hasmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Winkler, Tomas" <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6F5C1D715B2DA5498A628E6B9C124F04019BF36ABD-KS4eWWg9cz+vNW/NfzhIbrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-12-31 at 01:29 +0200, Winkler, Tomas wrote:
> 
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org]
> > Sent: Friday, December 31, 2010 1:06 AM
> > To: Winkler, Tomas; Stephen Hemminger; Johannes Berg
> > Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org ; linux-
> > wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: RE: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
> > skbs
> > 
> > Although copy is slower for large packets, this is a non performance path.
> > The code in question is for bridged multicast Ipv6 ICMP packets. This case
> > is so uncritical it could be done in BASIC and no one could possibly care!
> > 
> 
> 
> Fair enough, although you got few of those when you connect to win7 client. 
> Anyhow my fix would work if the second pull would be 
>   if (!pskb_may_pull(skb2, sizeof(struct mld_msg)))  instead of  (!pskb_may_pull(skb2, sizeof(*icmp6h)))

I don't think that works either since that may be longer than the entire
skb's length since the payload still is variable at this point.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
