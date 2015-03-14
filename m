From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH next] drivers: wireless: carl9170: shrink carl9170_tx_info
Date: Sat, 14 Mar 2015 18:55:32 +0100
Message-ID: <20150314175532.GH14761@breakpoint.cc>
References: <1426261045-22373-1-git-send-email-fw@strlen.de>
 <1689955.Ikz24aORLX@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1689955.Ikz24aORLX@debian64>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
> On Friday, March 13, 2015 04:37:25 PM Florian Westphal wrote:
> > its embededded inside rate_driver_data of the ieee80211_tx_info struct,
> > which in turn is stored in skb->cb[].
> > 
> > In order to shrink cb, we need to shrink ieee80211_tx_info which means
> > to downsize all users first.
> > 
> > Alternatively, one might be able to remove kref but
> > its less intrusive/simpler to use u32 for timeout handling.
> > 
> > Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
> > ---
> u32 jiffies... that's a lot of pointing (well not so much) and really 
> ugly casting (a lot). I guess it would be easier to just use a "per-queue"
> timeout watchdog like almost everybody else. This way, the driver will
> be ready for the next skb->cb shrink as well.
> 
> carl9170_tx_ampdu_timeout can be completely removed.

Maybe, but there is only so much I am willing to do with "compile
tested only" patches...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
