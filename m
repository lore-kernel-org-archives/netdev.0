From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 3/22] xfrm: Add offload management routines
Date: Wed, 26 Jan 2005 16:30:39 -0500
Message-ID: <1106775040.9845.31.camel@ori.thedillows.org>
References: <20041230035000.11@ori.thedillows.org>
	 <20041230035000.12@ori.thedillows.org>
	 <20050121144738.7155893e.davem@davemloft.net>
	 <1106373038.3691.39.camel@ori.thedillows.org>
	 <20050125221608.0cb067b2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050125221608.0cb067b2.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-25 at 22:16 -0800, David S. Miller wrote:
> On Sat, 22 Jan 2005 00:50:38 -0500
> David Dillow <dave@thedillows.org> wrote:
> >
> Note that kmalloc() and SLAB do guarentee whatever alignment is
> necessary to access the largest aligned C data type on a platform.
> So on sparc32 this is 8 bytes, on some it is 4 bytes.

I must be missing something, since I only need to ensure the items in
struct xfrm_offload are aligned correctly -- the pointers in the first
list_head need to be aligned for the platform. I'm assuming the compiler
will align them on a proper offset from the beginning of the struct, and
as long as kmalloc() gives me the proper alignment for a pointer, then I
don't see the problem.

The hardware will never DMA the base xfrm_offload struct, and only
possibly it's private area -- which I agree would need proper alignment.

Just for reference, here's xfrm_offload:

struct xfrm_offload
{
        struct list_head        bydev;
        struct net_device *     dev;
        atomic_t                refcnt;
};

I'm making the assumption that kmalloc() will give me back a pointer
that will have an acceptable alignment for the platform for all of the
pointers, as well as the refcnt.

> > I copied part of that code to xfrm_offload_alloc(), removing the part
> > that aligned the base xfrm_offload struct. 32 byte alignment seemed a
> > bit much, do you think it is needed? I'll be happy to add that if you
> > want.
> 
> Depends upon what you really need the alignment for.  If you need it
> due to some hardware restriction or whatever, that would be determined
> per device I guess.

Per above, it seems like I only need kmalloc()'s alignment for struct
xfrm_offload. I don't know what the user will put in his private area,
but I wanted to try to align it such that it had the same guarantee that
kmalloc() had. That was the purpose of doing the alignment math only in
xfrm_offload_priv().
-- 
David Dillow <dave@thedillows.org>
