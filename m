From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 3/22] xfrm: Add offload management routines
Date: Sat, 22 Jan 2005 01:00:35 -0500
Message-ID: <1106373635.3691.51.camel@ori.thedillows.org>
References: <20041230035000.11@ori.thedillows.org>
	 <20041230035000.12@ori.thedillows.org>
	 <20050121144738.7155893e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050121144738.7155893e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ Sorry, David, if you get this multiple times. Had a doh! moment... ]

On Fri, 2005-01-21 at 14:47 -0800, David S. Miller wrote: 
> On Thu, 30 Dec 2004 03:48:35 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > +static inline struct xfrm_offload *
> > +xfrm_offload_alloc(int sizeof_priv, struct net_device *dev)
> 
> This whole scheme looks buggy.  The intent is to 8-byte align
> the object, but look at what the code is actually doing.
> 
> Whatever kmalloc() returns to xfrm_offload_alloc() is directly
> used as the xfrm_offload pointer, and the members are initialized.
> 
> Then xfrm_offload_priv() does the alignments.

Right, I'm not worried about the alignment of the xfrm_offload, as I'm
assuming that kmalloc will give us something suitable. However, I do
want to make sure that the private section used by the driver is 8 byte
aligned in the face of a potentially oddly sized xfrm_offload struct.

Am I making a bad assumption that kmalloc() will give me a suitable
alignment for the base struct?

> It is clear that kmalloc() is always giving you 8-byte aligned
> data else the first time xfrm_offload_priv() is used you'd
> get a bogus pointer since xfrm_offload_alloc() initialized
> the object without first aligning the pointer.

The driver calls xfrm_offload_alloc(), then calls xfrm_offload_priv() to
get it's private struct, and inits that. I just want to make sure the
private struct is 8 byte aligned, which I assume (wrongly?) will be
sufficient to prevent misaligned accesses.

> We do something similar when we allocate netdevs, so have a look
> at how net/core/dev.c:alloc_netdev() works.

I copied part of that code to xfrm_offload_alloc(), removing the part
that aligned the base xfrm_offload struct. 32 byte alignment seemed a
bit much, do you think it is needed? I'll be happy to add that if you
want.
-- 
David Dillow <dave@thedillows.org>
