From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip, route: fix minor compile warning
Date: Thu, 17 Dec 2015 17:12:03 -0800
Message-ID: <20151217171203.723b4d16@xeon-e3>
References: <c43f41f31854bb0a27cc6cd6d9e465a28a94ffb9.1450106992.git.daniel@iogearbox.net>
	<20151214155104.GE6555@orbit.nwl.cc>
	<566EE5F0.9030504@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33218 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933301AbbLRBL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 20:11:57 -0500
Received: by mail-pa0-f51.google.com with SMTP id ur14so51062507pab.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 17:11:57 -0800 (PST)
In-Reply-To: <566EE5F0.9030504@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Dec 2015 16:53:20 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 12/14/2015 04:51 PM, Phil Sutter wrote:
> > On Mon, Dec 14, 2015 at 04:34:29PM +0100, Daniel Borkmann wrote:
> >> Seems like gcc (4.8.3) doesn't catch this false positive, triggering
> >> after 0f7543322c5f ("route: ignore RTAX_HOPLIMIT of value -1"):
> >>
> >>    iproute.c: In function 'print_route':
> >>    iproute.c:301:12: warning: 'val' may be used uninitialized in this function [-Wmaybe-uninitialized]
> >>       features &= ~RTAX_FEATURE_ECN;
> >>                ^
> >>    iproute.c:575:10: note: 'val' was declared here
> >>        __u32 val;
> >>              ^
> >> So just shut it up by initializing to 0.
> >
> > Hmm. Interestingly, my patch shouldn't have changed anything relevant
> > for gcc's decision. OTOH, I don't see a warning using gcc-4.9.3.
> 
> If I revert it, the warning is gone for me ;) perhaps some heuristic issue
> with that gcc version.
> 
> Cheers,
> Daniel

I don't see this warning on current master with gcc 4.9.2.
