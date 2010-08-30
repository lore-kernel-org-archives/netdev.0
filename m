From: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: mac80211 using different tx queue for frames with same TID and RA
Date: Mon, 30 Aug 2010 16:34:09 +0200
Message-ID: <201008301634.10122.helmut.schaa@googlemail.com>
References: <201008301601.12971.helmut.schaa@googlemail.com> <1283177480.3691.66.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1283177480.3691.66.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Monday 30 August 2010 schrieb Johannes Berg:
> On Mon, 2010-08-30 at 16:01 +0200, Helmut Schaa wrote:
> 
> > while debugging an issue in rt2x00 I've discovered that in some cases frames
> > with the same TID and RA end up in different tx queues (which causes problems
> > in rt2x00 when using aggregation).
> > 
> > Is this behavior expected and we need to handle that case in rt2x00 or is it
> > more likely a bug? At least I thought the select_queue implementation in
> > mac80211 was meant to always pick the same tx queue for skbs with the same
> > priority and hence it shouldn't happen that frames with the same TID are
> > queued into different tx queues.
> 
> Indeed, that seems like a bug. I don't see how this can happen though,
> since the code _appears_ to not use the sk_tx_queue_mapping when an
> ndo_select_queue method is present.

Hmm, this issue seems to only happen when the wifi interface (AP mode)
is part of a bridge and the frame is tx'ed through the bridge.

Helmut
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
