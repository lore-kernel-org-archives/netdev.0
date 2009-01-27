From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Mon, 26 Jan 2009 20:38:02 -0700
Message-ID: <1233027482.7148.42.camel@2710p.home>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090116211334.22836.72681.stgit@debian.lart>
	 <200901271300.30330.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200901271300.30330.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty,

On Tue, 2009-01-27 at 13:00 +1030, Rusty Russell wrote:
> On Saturday 17 January 2009 07:43:34 Alex Williamson wrote:
> > As with most real hardware, unicast addresses have priority in
> 
> > the filter table so we can avoid enabling full promiscuous
> 
> > until both unicast and multicast address overflow.
> 
> Why not pretend to have infinite, and have the host turn promisc on
> when *it*
> 
> decides? Skip the alloc call, and just use a feature bit like
> everything else?

I suppose it's just a matter of where do you want to add the smarts and
the tune-ability.  Since we can't actually have an infinite table and an
array implementation seems to make sense from an efficiency standpoint,
it needs to be defined by someone to be a fixed size before we start
using it.  I was hoping the guest driver might have a better idea how it
plans to use the filter table and that there'd be some benefit to having
that handshake happen between the driver and the backend.  The module
parameter fell out of this and seems rather convenient.

I could pursue this is you like, but I'm not sure of the benefit,
particularly if we want to give the user some control of the size of the
actual table.  Thoughts?  Thanks for the comments,

Alex 

-- 
Alex Williamson                             HP Open Source & Linux Org.

