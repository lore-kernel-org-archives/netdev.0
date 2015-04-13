From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Mon, 13 Apr 2015 13:17:13 +0200
Message-ID: <1428923833.2355.14.camel@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
	 <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
	 <alpine.LFD.2.11.1504111340170.2449@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.11.1504111340170.2449-c1lBKlETG9EWAawoAK+ZAw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-04-11 at 13:59 +0300, Julian Anastasov wrote:
> > + /*
> > +  *	For some 802.11 wireless deployments (and possibly other networks),
> > +  *	there will be an ARP proxy and gratuitous ARP frames are attacks
> > +  *	and thus should not be accepted.
> > +  */
> > +	if (IN_DEV_CONF_GET(in_dev, DROP_GRATUITOUS_ARP) && sip == tip)
> > +		goto out;
> 
> 	Does it happen for any pkt_type? 

Yes, it's supposed to.

> IN_DEV_ARP_ACCEPT
> is not ON by default, so new entries are not created but

Correct, this protects against "gratuitous updates" in a way.

> update can happen at any time, even with simple request like
> who-has OURIP tell PROXYIP and sha=hacker_mac sent by
> attackers. Is that the only gap that needs to be protected
> with this patch?

Realistically, I'd expect networks that deploy this to implement other
things that prevent clients from messing up the network. I'd expect, for
example, that ARP packets are simple dropped in the AP bridge if it
implements proxy service and wants to control the network tightly.

It can still be desirable to not let gratuitous ARP packets update the
cache entry though. IPv6 for example automatically marks such updated
entries stale, IIRC, so there I had even bigger issues with testing and
I need to check if I even need the 4th patch in this series.

However, there's also a compliance test here that requires this
behaviour, and checks specifically that a gratuitous ARP doesn't update
an existing cache entry.

> 	May be only arptable_filter can help here to
> protect ARP?

That could be possible, I'll check.

Thanks!

johannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
