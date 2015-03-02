From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH RFC 08/14] net: wireless: mac80211: shrink
 ieee80211_tx_info
Date: Mon, 2 Mar 2015 20:30:48 +0100
Message-ID: <20150302193048.GC9762@breakpoint.cc>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
 <1425318028-26531-9-git-send-email-fw@strlen.de>
 <1425322425.1906.4.camel@sipsolutions.net>
 <20150302190316.GB9762@breakpoint.cc>
 <1425323929.1906.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1425323929.1906.12.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Mon, 2015-03-02 at 20:03 +0100, Florian Westphal wrote:
> 
> > Eventually reducing skb size to make it fit into 3 cachelines again even
> > on 64bit architectures.  For that 40 bytes need to go.
> 
> That seems like a worthy goal I guess (I guess you should've copied a
> patch 0/N to us).

Indeed, sorry.
archived cover letter: http://marc.info/?l=linux-netdev&m=142531804325076&w=2

> > I'm not familiar with mac80211, aside from that it seemed to me
> > that 40 byte cb would be doable, given enough work.
> 
> Right now it is, mostly, yes.
> 
> > Where are to main problems, exactly?
> 
> Well, that depends. Right now clearly we're not really using all of it
> as you saw (even if this patch moving bits here and there is really
> ugly) but there are multiple things:
>  1) Of course mac80211 isn't static, it keeps getting developed! Right
> now for
>     example we need to fix single TCP flow throughput over wifi, and for
> that we
>     need a timestamp. That won't even fit into skb->cb any more right
> now; we'll
>     probably be able to get away with (ab)using skb->tstamp or doing
> reshuffling
>     similar to yours to get some space, but that's just lucky this time.
>  2) We're actually out of flags that are kept from TX generation to TX
>     destruction and it's almost certain that we'll need to add more
> things.
> 
> Also, we already do a lot of bit twiddling here, doing it even more
> makes the code even harder to follow. It's bad enough as is if you ask
> me.

True.

> > I known that pushing something into ->cb is a lot easier than e.g. keeping
> > extra state on stack, but, IMO cb should really only be used when you
> > need to associate data strictly with an skb so that this data is still
> > availabe even when skb gets queued somewehere.
> 
> Right, and we do that. We've in the past moved out data from here to
> elsewhere, but it's extremely tedious and error-prone, and I'm not sure
> we have much that we can possibly move now, since we do need to hang on
> to SKBs in many cases like client powersaving etc.

I see.  I cannot comment any further at the moment, I will have to dig
into mac80211 more.

Thanks for your comments!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
