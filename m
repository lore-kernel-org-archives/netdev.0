From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3] mac80211: mesh: set tx_info->hw_queue to the correct
 queue upon packet forwarding
Date: Thu, 11 Aug 2016 15:04:21 +0200
Message-ID: <1470920661.12075.12.camel@sipsolutions.net>
References: <20160808070610.20563-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160808070610.20563-1-yanivma-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-08-08 at 10:06 +0300, Yaniv Machani wrote:
> From: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>
> 
> MP received data frames from another MP. Frames are forwarded
> from Rx to Tx to be transmitted to a third MP.
> Upon cloning the skb, the tx_info was zeroed, and the
> hw_queue wasn't set correctly, causing frames to be
> inserted to queue 0 (VOICE). If re-queue occurred for some
> reason, frame will be inserted to correct queue 2 (BE).
> In this case frames are now dequeued from 2 different queues and
> sent out of order.

Uh, sorry. I was so focused on the commit message and everything that I
neglected to look into the code change ... :(

>  	info->control.jiffies = jiffies;
> +	info->hw_queue = q;
> 
This is incorrect. 'q' appears to be the AC here, so you need to set
something like vif->hw_queue[q], afaict? Check out tx.c where this is
set.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
