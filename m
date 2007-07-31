From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 31 Jul 2007 13:05:47 +0200
Message-ID: <20070731110547.GC12071@florz.florz.dyndns.org>
References: <20070731080719.GA12071@florz.florz.dyndns.org> <20070731.012609.41193630.davem@davemloft.net> <20070731090159.GB12071@florz.florz.dyndns.org> <20070731.021602.48807945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.169.56] ([77.10.169.56]:53025 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbXGaLF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 07:05:56 -0400
Content-Disposition: inline
In-Reply-To: <20070731.021602.48807945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > Actually it might be simpler and more efficient to just make
> > > PPPOE_HASH_SHIFT be 8.
> > 
> > SHIFT? SIZE? BITS?
> 
> You know what I meant :-)
> 
> PPPOE_HASH_BITS.

Actually, I wasn't sure, for "SHIFT" looks more similar to "SIZE"
than to "BITS", plus numbers are somewhat same order of magnitude
anyway, and I didn't quite see what you were up to, so ... whatever ;-)

> I guess otherwise we degenerate back to your original patch :)

Well, as I don't quite see what you were up to and as my patch doesn't
change anything about the semantics of the code, I'd at least prefer
that over your other suggestions so far ;-)

A few variations I tried back when I created the patch, using larger
things than a char for accumulating the pieces and then folding down
from that, turned out to be slower than what I finally submitted, at
least on the machines I tested it on. I didn't do comprehensive testing,
as it really doesn't matter, after all, but I think the version I
submitted is pretty fast, plus it's quite readable, and it keeps the
flexibility of different hash sizes, but still should allow the
compiler to optimize away the loops that allow for this flexibility.

Florian
