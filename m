From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] net, wireless: Don't return uninitialized in
 __cfg80211_stop_sched_scan()
Date: Wed, 29 Jun 2011 23:33:50 +0300
Message-ID: <1309379630.1514.122.camel@cumari>
References: <alpine.LNX.2.00.1106292212110.3747@swampdragon.chaosbits.net>
	 <1309379244.4071.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1309379244.4071.7.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-06-29 at 22:27 +0200, Johannes Berg wrote: 
> On Wed, 2011-06-29 at 22:13 +0200, Jesper Juhl wrote:
> > If the 'driver_initiated' function argument to
> > __cfg80211_stop_sched_scan() is not 0 then we'll return an
> > uninitialized 'ret' from the function.
> 
> 'err'. I also dislike the initialisation, can we just replace the
> "return err;" at the end of the function with "return 0;" instead?

Luckily we were never using the return value when passing
driver_initiate =- false.

And I agree with you, there's no use to return err at the end.  Better
to simply return 0.


> Luca, should it maybe be return -ENOENT anyway in the !sched_scan_req
> case?

We could do that.  I had just thought that stopping a scan that is not
running would just be a NOP, but if you prefer to return an error in
that case, I can do it.

-- 
Cheers,
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
