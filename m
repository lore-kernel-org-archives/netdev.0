From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] etherdevice: introduce eth_broadcast_addr
Date: Wed, 11 Jul 2012 09:27:34 +0200
Message-ID: <1341991654.4480.5.camel@jlt3.sipsolutions.net>
References: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
	 <20120708.235808.1602900783296556684.davem@davemloft.net>
	 <1341937124.4475.27.camel@jlt3.sipsolutions.net>
	 <CAP=VYLqNyAF1gSsKTd3YojeJXK_-pEzXAKyVQbQfwhtwOyMmwg@mail.gmail.com>
	 (sfid-20120711_021016_338821_DEFABE8B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAP=VYLqNyAF1gSsKTd3YojeJXK_-pEzXAKyVQbQfwhtwOyMmwg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20120711_021016_338821_DEFABE8B)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 20:09 -0400, Paul Gortmaker wrote:
> On Tue, Jul 10, 2012 at 12:18 PM, Johannes Berg
> <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> > From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >
> > A lot of code has either the memset or an inefficient copy
> > from a static array that contains the all-ones broadcast
> 
> Shouldn't we see all that "lot of code" here in this same
> commit, now using this new shortcut?  If we apply this, we
> have a new function, but with no users.  If you have done
> the audit, and found the inefficient cases, why isn't it here?

I'm planning to fix the wireless uses (at least the ones I'm responsible
for), but I'm just going to stick them into my mac80211-next tree after
this patch percolates down there, I don't see a need to send around a
ton of patches for it.

> I would think it better to just fix those people who have a
> pointless static array of all-ones to use the memset.  If it was a
> multi line thing to achieve the eth_broadcast_addr() then it
> might make sense to exist.  But as a one line alias, it does
> seem somewhat pointless to me.

At least in my code I'm going to prefer this over the memset for
documentation purposes. I'll agree that memset(..., 0xff, ETH_ALEN) is
pretty obvious already, but eth_broadcast_addr(...) is even easier to
read IMHO.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
