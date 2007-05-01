From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: Re: [PATCH] zd1211rw-mac80211: limit URB buffering in tx path
Date: Tue, 1 May 2007 21:50:08 +0200
Message-ID: <20070501195008.GA14294@p15091797.pureserver.info>
References: <20070501030100.BDE3D7B409F@zog.reactivated.net> <20070501123411.081c43c6@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070501123411.081c43c6-NimcoU2PGpwZjWj6TdD+Jg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07-05-01 12:34 Jiri Benc wrote:

> On Tue,  1 May 2007 04:01:00 +0100 (BST), Daniel Drake wrote:
> > The old code allowed unlimited buffing of tx frames in URBs
> > submitted for transfer to the device. This patch stops the
> > ieee80211_hw queue(s) if to many URBs are ready for submit to the
> > device. Actually the ZD1211 device supports currently only one
> > queue.
> 
> This doesn't look correct to me. The limits should be per queue and you
> should always stop queues selectively.

The old ZD1211 chip doesn't support queuing and the new ZD1211B
chip has support, but it is unclear how to put packets in the
different queues. However the error condition here is, that
packets can't be transmitted over the USB, which will affect all
queues. Sure one could manage different high level marks for the
different queues, but this is all theoretical currently. I could
have coded with the explicit knowledge that we support only one
queue, but it is really work the hassle.

> > +/**
> > + * wake_queues - wakes all queues
> > + * @hw: a &struct ieee80211_hw pointer
> > + *
> > + * Such a function is not provided by mac80211, so we have to provide them on
> > + * our own.
> > + */
> > +static void wake_queues(struct ieee80211_hw *hw)
> 
> It is :-) Look for ieee80211_wake_queues. But as I said, you shouldn't need
> that.

I provided the patch to add ieee80211_wake_queues(). Sorry for
missing the moment, when it has been integrated. I will update the
patch.

-- 
Uli Kunitz
