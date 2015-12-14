From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip, route: fix minor compile warning
Date: Mon, 14 Dec 2015 16:51:04 +0100
Message-ID: <20151214155104.GE6555@orbit.nwl.cc>
References: <c43f41f31854bb0a27cc6cd6d9e465a28a94ffb9.1450106992.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35302 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbbLNPvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 10:51:07 -0500
Content-Disposition: inline
In-Reply-To: <c43f41f31854bb0a27cc6cd6d9e465a28a94ffb9.1450106992.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2015 at 04:34:29PM +0100, Daniel Borkmann wrote:
> Seems like gcc (4.8.3) doesn't catch this false positive, triggering
> after 0f7543322c5f ("route: ignore RTAX_HOPLIMIT of value -1"):
> 
>   iproute.c: In function 'print_route':
>   iproute.c:301:12: warning: 'val' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      features &= ~RTAX_FEATURE_ECN;
>               ^
>   iproute.c:575:10: note: 'val' was declared here
>       __u32 val;
>             ^
> So just shut it up by initializing to 0.

Hmm. Interestingly, my patch shouldn't have changed anything relevant
for gcc's decision. OTOH, I don't see a warning using gcc-4.9.3.

Cheers, Phil
