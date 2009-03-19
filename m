From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 address printf format specifier
Date: Wed, 18 Mar 2009 18:58:26 -0700 (PDT)
Message-ID: <20090318.185826.221840814.davem@davemloft.net>
References: <4B97CD05-9949-485D-987E-A555FCBC2F5A@oracle.com>
	<49BE889C.8080602@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751071AbZCSB6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:58:39 -0400
In-Reply-To: <49BE889C.8080602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 16 Mar 2009 13:13:00 -0400

> Chuck Lever wrote:
> > The NFS and RPC code in the kernel now uses the new printf format
> > specifier for IPv6 addresses.  In some cases, the generated address
> > string is sent out of the kernel (for example, it is used to build a
> > universal address for RPCB_SET requests, and used as the mon_name in
> > some SM_MON upcalls to our rpc.statd).
> > 
> > The problem is that outside the kernel, applications generally use
> > getnameinfo(3) or inet_ntop(3) to do this conversion.  The library
> > follows the RFC suggestion of shortening these address strings by
> > replacing the longest series of zeroes in the IPv6 address with "::".
> > 
> > Since the kernel doesn't do that, string comparisons don't work when
> > comparing address strings that came from our kernel.  Since these
> > address strings appear to other hosts (via the rpcbind registry) this
> > is, or could become, an interoperability issue for Linux.
> > 
> > How should I fix this?
> > 
> > 1.  Copy glibc's code to the printf logic for %pI6
> 
> I think this is the optimum solution.  This normalizes kernel output
> with that of user-space thus creating a uniform format.
> 
> My $0.02

Then you'll break cases where this string is output via
some /proc/ file or whatever and it expects the existing
behavior.

I don't think we can do this.
