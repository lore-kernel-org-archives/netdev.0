From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 15:40:03 -0700 (PDT)
Message-ID: <20060428.154003.25335370.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143B10A@NT-SJCA-0751.brcm.ad.broadcom.com>
	<1146262622.8029.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51593
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751788AbWD1Wj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:39:57 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1146262622.8029.63.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 29 Apr 2006 08:17:01 +1000

> On Fri, 2006-04-28 at 10:55 -0700, Caitlin Bestler wrote:
> > vj_netchannels represent a strategy of minimizing
> > registration/pinning costs even if it means paying for an extra copy.
> > Because the extra copy is closely tied to the activation of the data
> > sink consumer the cost of that extra copy is greatly reduced because
> > it places the data in the cache immediately before the application
> > will in fact use the received data.
> 
> Just to be clear here: I agree with Dave that without classifying
> hardware, there's no point (and much pain) in going all the way to
> userspace with the channel (ie. mmap).  If you're going to copy anyway,
> might as well do it in the socket's read() call: then the user can then
> aim the copy exactly where they want, too.  We'll need that TCP code in
> the kernel for the foreseeable future anyway 8)
> 
> However, in future, if intelligent cards exist, having an API which lets
> them do zero-copy and not overly penalize less intelligent cards makes
> sense.

I do not think intelligent cards imply protocol in user space.
You can still get the zero copy, and moving the work to the
remote cpu, without all the complexity assosciated with putting
the protocol in userspace.  It buys nothing but complexity.

> Side note: my Xen I/O patches allow the implementation of exactly this
> kind of virtual hardware (no coincidence 8), so intelligent cards might
> not be as far away as you think...

Such hardware can be prototyped in QEMU as well.
