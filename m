From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 03 Sep 2014 11:40:55 +0200
Message-ID: <1409737255.1932.5.camel@jlt4.sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 <20140902141620.2da1f6aa@urahara> (sfid-20140902_231626_427316_AF0944A4)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140902141620.2da1f6aa@urahara> (sfid-20140902_231626_427316_AF0944A4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-02 at 14:16 -0700, Stephen Hemminger wrote:
> On Thu, 21 Aug 2014 19:22:27 +0200
> Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> 
> > +	/* RFC 1122 3.3.6:
> > +	 *
> > +	 *   When a host sends a datagram to a link-layer broadcast address,
> > +	 *   the IP destination address MUST be a legal IP broadcast or IP
> > +	 *   multicast address.
> > +	 *
> > +	 *   A host SHOULD silently discard a datagram that is received via
> > +	 *   a link-layer broadcast (see Section 2.4) but does not specify
> > +	 *   an IP multicast or broadcast destination address.
> > +	 *
> > +	 * We also do this for link-layer multicast.
> > +	 */
> > +	if ((skb->pkt_type == PACKET_BROADCAST ||
> > +	     skb->pkt_type == PACKET_MULTICAST) &&
> > +	    res.type != RTN_BROADCAST)
> > +		goto e_inval;
> > +
> 
> I think you need to all multicast packet but not broadcast.
> The RFC does not specify that you should drop link-layer multicast to a unicast
> address. There are several clustering products use that.

Alright - I feared we'd not be able to do this. Based on a strict
reading of the RFC, you're right. I'm not sure what thinking and
rationale went into this sentence in the RFC, depending on that it would
have made sense to me to also apply it for broadcast (which is really
just a special form of multicast, in a sense, no?)

In any case, for wireless we do need broadcast as well, for obvious
reasons. Therefore, I think with all the discussion here and about IPv6
etc. we're getting to the point where we should think about
disentangling RFC 1122 checks (which may very well be correct and needed
in their own right) and the hole-196 mitigation for wireless.

Our original attempt is documented here:
http://patchwork.ozlabs.org/patch/293133/

and there seemed to be consensus back then that we should do it in the
wireless stack. I can live with that, even if I don't very much like the
idea of dissecting IP protocols there and having to do a route lookup
etc. In any case, if that's what we want to do, I'll probably need some
help on how to do the route lookups etc. Any takers? :)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
