From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 06:40:52 -0400
Message-ID: <20090521104052.GB25369@hmsreliant.think-freely.org>
References: <20090521004634.GB29869@localhost.localdomain> <20090521020541.GD5956@ghostprotocols.net> <20090521022621.GA2173@localhost.localdomain> <20090520.205044.185308597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, netdev@vger.kernel.org, vanhoof@redhat.com,
	williams@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44366 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbZEUKlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 06:41:01 -0400
Content-Disposition: inline
In-Reply-To: <20090520.205044.185308597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 08:50:44PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 20 May 2009 22:26:21 -0400
> 
> > I agree, your way of doing this definately lets you layer on top of
> > the existing vetted implementation, which is nice, I just thought
> > that avoiding the creation of another syscall might be worth a
> > little extra work in the kernel.  Instead of arrays of msghdrs, We'd
> > be looking at chains like this: msghdr->(struct msghdr
> > *)msg_control[i].data->msghdr->etc
> > 
> > Not too hard to parse, I dont think.  But I'll defer to brighter
> > minds than mine.  If the creation of another syscall isn't too
> > difficult a barrier to overcome (assuming this is going to occur for
> > sendmsg, and various other i/o ops as well), then your way here is
> > probably the way to go.
> 
> Unfortunately you can't use msg flags for this.
> 
> We accept any message flag we don't understand without signalling
> any errors.
> 

I assume that silently ignoring flags we don't understand is a specified part
of the sockets api?  I was looking at the posix definition of recvmsg and I
don't see where its required that we ignore unknown flags (although I can see
why it would be usefull to do so)

> So there is no way to determine if the kernel supports the flag
> or not.  Whereas with a socket option, we'll always get an error
> on older kernels for unsupported options.
> 
> I think the system call is the cleanest, because it's not only a
> semantic change but also a data type change.  I also think the
> socket option scheme is too cumbersome.  I think it would be
> common for an application to want to use both modes of sending,
> especially if that application uses lots of existing library
> mode to compose some messages.  And extra setsockopt() around
> every call down into that library?  Yikes, good luck getting
> that right all the time.  It's way too error prone.

The new system call is definately cleaner, as it lets you specify the array
semantics in a way that is much more efficient and less cumbersome for both user
and kernel space.  I just thought I'd propose an alternate method that avoids
the need for a new syscall.  It sounds like you and Acme have already hashed
through this though, so I'll sit down :)

Thanks guys!
Neil

