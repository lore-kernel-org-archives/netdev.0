From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio: use __GFP_NOWARN for try_fill_recv in virtnet_poll
Date: Tue, 15 Feb 2011 21:39:03 +1030
Message-ID: <201102152139.03451.rusty@rustcorp.com.au>
References: <20110215093527.GB8341@tiehlicka.suse.cz> <201102152041.29179.rusty@rustcorp.com.au> <20110215102549.GD8341@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michal Hocko <mhocko@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54528 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090Ab1BOLJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 06:09:07 -0500
In-Reply-To: <20110215102549.GD8341@tiehlicka.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Feb 2011 08:55:50 pm Michal Hocko wrote:
> On Tue 15-02-11 20:41:29, Rusty Russell wrote:
> > On Tue, 15 Feb 2011 08:05:27 pm Michal Hocko wrote:
> > > Hi,
> > > we have started seeing a lot of allocator messages complaining about
> > > failed allocations from virtnet_poll in soft IRQ. Could you consider the
> > > following patch, please?
> > 
> > Do we really want to silence this?  Isn't warning about it kind of the
> > point?  Your network is probably sucking if this happens...
> 
> What can user do about it? Is the low level memory allocator message
> very much usefull for him?  Maybe we can add a printk_once in the fail
> path with some more useful and virtio specific message.

That's an argument against ever printing any message.

What we need to know is why does this happen with virtio_net and not other
cards?  If it happens to them too, and they silently fall back, all good.

I want to make sure we're not papering over a real problem...

Thanks,
Rusty.
