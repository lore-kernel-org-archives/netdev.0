From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 18:03:00 -0700 (PDT)
Message-ID: <20080503.180300.10562559.davem@davemloft.net>
References: <1209760731.3608.17.camel@johannes.berg>
	<20080502.163334.148944203.davem@davemloft.net>
	<1209815533.3987.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209815533.3987.21.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Sat, 03 May 2008 13:52:13 +0200

> 
> > We can't update skb->truesize during arbitray skb->data reallocations,
> > because it could corrupt the socket accounting.
> > 
> > On the other hand, if we provide ways for users to subvert the socket
> > buffer limits, we might as well not try to limit anything.
> 
> Why don't we update the socket allocation when doing pskb_expand_head()?
> Sure, it could become negative, but is that so bad?

The socket locked state at this time is variable and unknown.

The socket must be locked in order to modify these values.
And such locks cannot be taken, for example, from HW interrupt
context, amongst other restrictions.

> We need more space though. Should we then just increase the built-in
> headroom?

I simply don't know what to suggest at this point, that's why
we are having this discussion :-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
