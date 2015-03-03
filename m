From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next 13/14] wireless: Use eth_<foo>_addr instead of
 memset
Date: Tue, 03 Mar 2015 10:00:19 +0100
Message-ID: <1425373219.2450.13.camel@sipsolutions.net>
References: <cover.1425354527.git.joe@perches.com>
	 <0c710456e4875ff00c1a9fcff9378ed15110dcd3.1425354528.git.joe@perches.com>
	 <1425370617.2450.3.camel@sipsolutions.net>
	 <1425371858.17273.3.camel@perches.com>
	 <1425372295.2450.9.camel@sipsolutions.net>
	 <1425372748.17273.6.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425372748.17273.6.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 00:52 -0800, Joe Perches wrote:

> > > My guess is the eth_zero_addr and eth_broadcast functions
> > > are always taking aligned(2) arguments, just like all the
> > > is_<foo>_ether_addr functions.
> > 
> > Err, are you serious???
> 
> Yes.
> 
> > That *clearly* isn't true, and if it was then
> > this patch wouldn't be safe at all.
> 
> And why is that?
> 
> Until patch 1 of this series, eth_zero_addr and
> eth_broadcast_addr was just an inline for a memset.
> 
> Even after patch 1, it's effectively still memset.

Exactly. It therefore *doesn't* require an aligned(2) argument, unlike
what you stated above, hence my question if you're serious (and perhaps
looking at some other code that I don't have).

My argument/complaint is that it isn't obvious from these which ones do
require aligned(2) argument. Therefore, it's not obvious without going
back to the definitions where the conversion is safe and where it isn't.
Clearly, for example, memcmp() cannot always be replaced with
ether_addr_equal().

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
