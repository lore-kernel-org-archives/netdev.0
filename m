From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6.X] 32->64 bit conversion for wireless private ioctl
Date: Thu, 24 Jun 2004 17:36:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625003617.GA6876@bougret.hpl.hp.com>
References: <20040624234307.GA5514@bougret.hpl.hp.com> <20040625001557.GA19939@havoc.gtf.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Andi Kleen <ak@suse.de>,
        Pavel Machek <pavel@suse.cz>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040625001557.GA19939@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 24, 2004 at 08:15:57PM -0400, Jeff Garzik wrote:
> 
> You missed what I was trying to communicate :(
> 
> It is a logical contradiction to create a generic interface for
> driver-private ioctls.  You wind up re-inventing Sun XDR.

	Any interface for device specific stuff has to be generic, it
doesn't matter if you use ioctl, netlink, module parameters or
pseudo-filesystem.
	Now, we can debate if this generic interface should use ioctl
or something else, that's a different issue. I hope you will have
noticed that some drivers, such as Orinoco, got rid of their
pseudo-filesystem and converted to iwpriv (you may ask David why he
did that). So, it's probably not as bad as you claim...

	The point is that this interface exist, is in use, so we might
as well make it 64 bit clean. Therefore patch.

> We want to go in the opposite direction:  compile and verify as much
> code as possible at compile time.  Strong, compile-time type checking.

	I wonder how you are going to do that for device specific
stuff with strong compile time checks. If you convert everything to a
binary pseudo-file, which doesn't change anything to the problem. Or
you can use a text pseudo-file, which mean a dedicated parser or a
generic parsing infrastructure, and performance penalty. You can't
win.
	Maybe all the device specific APIs should use XML. That's the
future, and allow to validate the userspace input. Next week, I'll
convert all Wireless Extension to XML ;-)

> 	Jeff

	Regards,

	Jean
