From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.X] 32->64 bit conversion for wireless private ioctl
Date: Thu, 24 Jun 2004 21:23:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625012331.GD19939@havoc.gtf.org>
References: <20040624234307.GA5514@bougret.hpl.hp.com> <20040625001557.GA19939@havoc.gtf.org> <20040625003617.GA6876@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Andi Kleen <ak@suse.de>,
        Pavel Machek <pavel@suse.cz>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040625003617.GA6876@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 24, 2004 at 05:36:17PM -0700, Jean Tourrilhes wrote:
> On Thu, Jun 24, 2004 at 08:15:57PM -0400, Jeff Garzik wrote:
> > 
> > You missed what I was trying to communicate :(
> > 
> > It is a logical contradiction to create a generic interface for
> > driver-private ioctls.  You wind up re-inventing Sun XDR.
> 
> 	Any interface for device specific stuff has to be generic, it
> doesn't matter if you use ioctl, netlink, module parameters or
> pseudo-filesystem.
> 	Now, we can debate if this generic interface should use ioctl
> or something else, that's a different issue. I hope you will have
> noticed that some drivers, such as Orinoco, got rid of their
> pseudo-filesystem and converted to iwpriv (you may ask David why he
> did that). So, it's probably not as bad as you claim...
> 
> 	The point is that this interface exist, is in use, so we might
> as well make it 64 bit clean. Therefore patch.

You're still missing the point.  This 'private_args' interface should
not exist at all.  Making it 64-bit clean doesn't help anything (it
still needs to be endian clean as well, but even that's not the point).
It's a run-time type interface when all other net drivers have managed
to avoid such a thing.  It's overly complex, and is a "black hole"
interface that discourages wireless authors from coming together and
developing more common pieces.

It's just not Linux in so many ways.  Please, look at how the other
interfaces in the kernel are designed, and how they evolve over time.


> > We want to go in the opposite direction:  compile and verify as much
> > code as possible at compile time.  Strong, compile-time type checking.
> 
> 	I wonder how you are going to do that for device specific
> stuff with strong compile time checks. If you convert everything to a

See various implementations of SIOCDEVPRIVATE.

	Jeff
