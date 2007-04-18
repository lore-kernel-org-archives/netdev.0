From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8349] New: Manually set IPv6 default route
 ignored
Date: Tue, 17 Apr 2007 20:00:38 -0700
Message-ID: <20070417200038.b85cdcb5.akpm@linux-foundation.org>
References: <200704180145.l3I1jCOo025906@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linkfanel@yahoo.fr,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45108 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965345AbXDRDAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 23:00:45 -0400
In-Reply-To: <200704180145.l3I1jCOo025906@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Apr 2007 18:45:12 -0700 bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8349
> 
>            Summary: Manually set IPv6 default route ignored
>     Kernel Version: 2.6.20.7
>             Status: NEW
>           Severity: normal
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: linkfanel@yahoo.fr
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.19.5
> Distribution: Debian sid
> Hardware Environment: x86 (Pentium 4/MMX)
> Software Environment: iproute2-ss060323, ifupdown 0.6.8
> 
> Problem Description:
> Default routes added to the IPv6 routing table, which are not coming from
> autoconfiguration, seem to be ignored. Subsequently, IPv6 routing is disrupted,
> and for instance calls to connect() fail with an ENETUNREACH error.
> 
> Steps to reproduce:
> 0. Find an IPv6-enabled box on an IPv6-free network. In the absence of any other
> configuration, the routing table contains the single line:
> fe80::/64 dev eth0 ...
> 1. Add a default route:
> ip -6 ro add default via fe80::1 dev eth0
> 2. Try to do IPv6, for instance:
> # ping6 2001:4978:1:110:0:ac:ce55:1b1e
> connect: Network is unreachable
> (returns instantly, no packet is sent)
> 
> This bug is present in the last stable 2.6.20.7 kernel, and in 2.6.21-rc7. I
> actually came across this bug on a server on a network where IPv6 is routed and
> advertised, but with autoconfiguration disabled on this server. It *seems* to me
> that if the interface is brought up with accept_ra enabled, default routes,
> including the one got from RA and ones input by hand later will work, whereas if
> it is brought up with accept_ra disabled (or no RA is received), the problem
> will occur. Note that routes with a non-null prefix length, such as 3 or 1, work
> fine.
