From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 3 Aug 2006 13:28:36 -0400
Message-ID: <20060803172836.GF20603@thunk.org>
References: <20060803075704.GC27835@thunk.org> <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au> <20060803163204.GB20603@thunk.org> <20060803094917.8280f5ff.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:5042 "EHLO thunker.thunk.org")
	by vger.kernel.org with ESMTP id S964802AbWHCR2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 13:28:44 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20060803094917.8280f5ff.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 09:49:17AM -0700, Randy.Dunlap wrote:
> Interesting.  On my Dell D610 notebook with tg3 and vpn,
> I have to ping a server on the vpn to keep it alive, otherwise
> it disappears soon and I have to restart the vpn.  Of course,
> this could just be the vpn or some other software problem
> instead of a tg3 problem.

That sounds almost certainly like a VPN problem.  The tg3_timer() code
wakes up every second or tenth of a second (depending on which mode
you're in) and takes care of keeping the tg3 hardware mollified.  On a
standard kernel, this shouldn't ever be an issue.  For the -rt kernel,
this problem only shows up if you have enough tasks running at
rtprio's above the rtprio of the softirq-timer for long enough that
tg3 chip gets angry....

						- Ted
