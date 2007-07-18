From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: fix GCC warning on 64bit platforms
Date: Wed, 18 Jul 2007 18:27:40 +0200
Message-ID: <20070718182740.69addc09@griffin.suse.cz>
References: <20070714.185935.18577806.davem@davemloft.net>
	<20070714.204116.23012949.davem@davemloft.net>
	<20070716184653.355253bf@griffin.suse.cz>
	<20070716.145358.35015496.davem@davemloft.net>
	<20070718171044.2de287cd@griffin.suse.cz>
	<469E3C70.4070809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <469E3C70.4070809-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 11:14:40 -0500, Larry Finger wrote:
> > -	local->tx_headroom = max(local->hw.extra_tx_headroom,
> > -				 sizeof(struct ieee80211_tx_status_rtap_hdr));
> > +	local->tx_headroom = max_t(unsigned, local->hw.extra_tx_headroom,
> > +				   sizeof(struct ieee80211_tx_status_rtap_hdr));
> >  
> >  	debugfs_hw_add(local);
> 
> For my info on how to use max_t, not as a critique of this patch.
> (1) Is 'unsigned' enough or should it be 'unsigned int'?

Don't know. For a C compiler, it doesn't matter, but it's fact that
most of the code in the kernel uses "unsigned int".

> (2) Because tx_headroom is an int, why use unsigned at all?

Because hw.extra_tx_headroom is unsigned. tx_headroom should be IMO
unsigned too but that's not just a matter of changing its type as it
would mean a lot of new warnings. We're talking about numbers several
orders less than int, so it's not an issue here anyway.

If you think "int" is more appropriate, fine with me, I don't really
care.

 Jiri

-- 
Jiri Benc
SUSE Labs
