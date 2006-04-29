From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Sat, 29 Apr 2006 10:22:40 +1000
Message-ID: <1146270160.8029.78.camel@localhost.localdomain>
References: <54AD0F12E08D1541B826BE97C98F99F143B10A@NT-SJCA-0751.brcm.ad.broadcom.com>
	 <1146262622.8029.63.camel@localhost.localdomain>
	 <20060428.154003.25335370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:30641 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1030253AbWD2AXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 20:23:08 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060428.154003.25335370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-28 at 15:40 -0700, David S. Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Sat, 29 Apr 2006 08:17:01 +1000
> > However, in future, if intelligent cards exist, having an API which lets
> > them do zero-copy and not overly penalize less intelligent cards makes
> > sense.
> 
> I do not think intelligent cards imply protocol in user space.
> You can still get the zero copy, and moving the work to the
> remote cpu, without all the complexity assosciated with putting
> the protocol in userspace.  It buys nothing but complexity.

You're thinking the card would place the packet in the mmap'ed buffer,
but the protocol handling would still be done (on that user-accessible
buffer) in kernelspace?

I hadn't considered that.  Are the userspace-kernel interactions here
are a lesser problem than telling userspace "you want direct access to
the packets?  Great, *you* handle the whole thing".

I am thinking the big payoff for this would be MPI et al (RDMA), so we
might be best leaving it alone.

> > Side note: my Xen I/O patches allow the implementation of exactly this
> > kind of virtual hardware (no coincidence 8), so intelligent cards might
> > not be as far away as you think...
> 
> Such hardware can be prototyped in QEMU as well.

Absolutely (and writing QEMU devices is easier than writing a Linux
device driver, which says something sad).  

But the Xen virtual intelligent NIC would be a "real" NIC, not (just) a
prototype.

Cheers!
Rusty.
-- 
 ccontrol: http://ozlabs.org/~rusty/ccontrol

