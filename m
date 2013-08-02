From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: changing dev->needed_headroom/needed_tailroom?
Date: Fri, 2 Aug 2013 10:55:58 +0200
Message-ID: <1375433758.24371.20.camel@deadeye.wl.decadent.org.uk>
References: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1374850210.8248.59.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-26 at 16:50 +0200, Johannes Berg wrote:
> Does it seem reasonable to change dev->needed_headroom and
> dev->needed_tailroom on the fly?
> 
> We currently set needed_headroom to the max of what we need, but we
> could do better like making it depend on the interface type (e.g. only
> asking for mesh space on mesh interfaces). This would be done only when
> the interface isn't connected, I can't promise it would be down but the
> carrier would be off.
[...]

I don't think this is safe when the interface is running (even if
carrier is off).  Some functions may read dev->needed_headroom twice and
rely on getting the same value each time.

Also, stacked devices would need to adjust their own needed_headroom
accordingly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
