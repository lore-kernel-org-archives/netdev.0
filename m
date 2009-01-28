From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Wed, 28 Jan 2009 21:15:13 +1030
Message-ID: <200901282115.14083.rusty@rustcorp.com.au>
References: <20090116211312.22836.34331.stgit@debian.lart> <200901271300.30330.rusty@rustcorp.com.au> <1233027482.7148.42.camel@2710p.home>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49929 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbZA1KqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2009 05:46:21 -0500
In-Reply-To: <1233027482.7148.42.camel@2710p.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 January 2009 14:08:02 Alex Williamson wrote:
> Hi Rusty,
> 
> On Tue, 2009-01-27 at 13:00 +1030, Rusty Russell wrote:
> > On Saturday 17 January 2009 07:43:34 Alex Williamson wrote:
> > > As with most real hardware, unicast addresses have priority in
> > 
> > > the filter table so we can avoid enabling full promiscuous
> > 
> > > until both unicast and multicast address overflow.
> > 
> > Why not pretend to have infinite, and have the host turn promisc on
> > when *it*
> > 
> > decides? Skip the alloc call, and just use a feature bit like
> > everything else?
> 
> I suppose it's just a matter of where do you want to add the smarts and
> the tune-ability.  Since we can't actually have an infinite table and an
> array implementation seems to make sense from an efficiency standpoint,
> it needs to be defined by someone to be a fixed size before we start
> using it.  I was hoping the guest driver might have a better idea how it
> plans to use the filter table and that there'd be some benefit to having
> that handshake happen between the driver and the backend.  The module
> parameter fell out of this and seems rather convenient.
> 
> I could pursue this is you like, but I'm not sure of the benefit,
> particularly if we want to give the user some control of the size of the
> actual table.  Thoughts?  Thanks for the comments,

I don't think the either-or case is real.  Say the user decides they want a table of 1000000 entries.  And the backend says "no way, I have a 16 array"?  Currently you get nothing.

I guess your qemu code does dynamic allocation.  But I'm sure you put a limit in there, right? :)

We don't want some complex negotiation, and I don't think the guest has any more clue than the host, nor can do much about it.

Cheers,
Rusty.
