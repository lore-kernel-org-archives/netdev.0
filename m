From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
 implementation
Date: Thu, 13 Aug 2009 00:46:04 +0400
Message-ID: <20090812204604.GA26366@doriath.ww600.siemens.net>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
 <1249914466.32614.13.camel@johannes.local>
 <20090811202304.GA6303@doriath.ww600.siemens.net>
 <1250023198.13529.69.camel@johannes.local>
 <20090812130605.GA17169@doriath.ww600.siemens.net>
 <1250082837.8784.21.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Sergey Lapin <slapin@ossfans.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:33739 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbZHLUqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 16:46:47 -0400
Content-Disposition: inline
In-Reply-To: <1250082837.8784.21.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 03:13:57PM +0200, Johannes Berg wrote:
> On Wed, 2009-08-12 at 17:06 +0400, Dmitry Eremin-Solenikov wrote:
> 
> > > In addition to that, you can't put anything into skb->cb, then push the
> > > frame to the master netdev, and expect things in skb->cb to still be
> > > there when the frame arrives at the master netdev. Not sure you do that
> > > (I hope not because that would be very buggy), but eventually you'll
> > > probably find that you do want that, etc.
> > 
> > Hmm. It works for us. Could you please tell me more about the problems
> > with skb->cb ?
> 
> Uh, well, you don't own the skb->cb between dev_queue_xmit() and
> ndo_start_xmit(). In fact, your phy_cb data will be overwritten by the
> qdisc.

Hmmm. Really weird. Then, if we want to pass data from socket layer to
MAC layer, we should place data in skb->data and not in skb->cb (like
radiotap header)?

> Also, looking into this a bit more, I see no reason to allocate a work
> struct every time you get a frame -- better just queue them up and stick
> everything else into skb->cb. In fact, you don't need a master netdev
> here anyway, just move all code from ieee802154_master_hard_start_xmit()
> into ieee802154_net_xmit().
> 

Nice idea. Thanks a lot!

-- 
With best wishes
Dmitry

