From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Subject: Re: [Bugme-new] [Bug 8635] New: EV6 version of csum_ipv6_magic causing unaligned access errors
Date: Sat, 16 Jun 2007 20:44:25 +0400
Message-ID: <20070616204425.A6514@jurassic.park.msu.ru>
References: <bug-8635-10286@http.bugzilla.kernel.org/> <20070616000620.72e56b86.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Richard Henderson <rth@twiddle.net>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jurassic.park.msu.ru ([195.208.223.243]:3297 "EHLO
	jurassic.park.msu.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbXFPRDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2007 13:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20070616000620.72e56b86.akpm@linux-foundation.org>; from akpm@linux-foundation.org on Sat, Jun 16, 2007 at 12:06:20AM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 16, 2007 at 12:06:20AM -0700, Andrew Morton wrote:
> > kernel unaligned acc    : 34 (pc=fffffc00004bbf58,va=fffffc000394811c)
> > 
> > fffffc00004bbdb0 T __copy_user
> > fffffc00004bbf50 T csum_ipv6_magic
> > fffffc00004bc020 T memchr
> > 
> > Seems to be associated w/ arch/alpha/lib/ev6-csum_ipv6_magic.S
> > 
> > Steps to reproduce:
> > 
> > Use IPv6 on an Alpha EV6 or higher CPU.
> > 
> 
> I assume that networking passed the arch an unaligned pointer and the arch
> didn't expect that.
> 
> I further assume that this is an alpha shortcoming, and that this behaviour
> of networking is expected?

Indeed, it's alpha bug. The struct in6_addr passed to this routine has
4 byte alignment, so we cannot use normal 64 bit loads.

Hopefully I'll have a fix shortly. BTW, it's not only ev6, ev5 variant
is broken as well.

Ivan.
