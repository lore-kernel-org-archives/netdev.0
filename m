From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] Fix sorting of SACK blocks
Date: Fri, 26 Jan 2007 08:40:09 +0200
Message-ID: <20070126064009.GE22455@galon.ev-en.org>
References: <20070125182903.GA22455@galon.ev-en.org> <20070125.155532.78711708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:43955
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030797AbXAZGkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 01:40:11 -0500
Content-Disposition: inline
In-Reply-To: <20070125.155532.78711708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070126 01:55]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Thu, 25 Jan 2007 20:29:03 +0200
> 
> > The sorting of SACK blocks actually munges them rather than sort, causing the
> > TCP stack to ignore some SACK information and breaking the assumption of
> > ordered SACK blocks after sorting.
> > 
> > The sort takes the data from a second buffer which isn't moved causing
> > subsequent data moves to occur from the wrong location. The fix is to
> > use a temporary buffer as a normal sort does.
> > 
> > Signed-Off-By: Baruch Even <baruch@ev-en.org>
> 
> BTW, in reviewing this I note that there is now only one remaining
> use of tp->recv_sack_cache[] and that is the code earlier in this
> function which is trying to detect if all we are doing is extending
> the leading edge of a SACK block.
> 
> It would be nice to be able to clear out that usage as well, and
> remove recv_sack_cache[] and thus make tcp_sock smaller.

You actually need recv_sack_cache to detect if you can use the fast
path. Another alternative is to somehow hash the values of the sack
blocks but then you rely on probabilty that you will properly detect the
ability to use the fast path. Hashing will save some space but you can't
get rid of it completely unless you go back to the old and slow method
of SACK processing.

There were thoughts thrown a while back about using a different data
structure, I think you said you started working on something like that.
If that comes to fruition the cache might go.

FWIW, my other mail about possible bugs actually says that you might
need to add another value to check, the number of sack blocks in the
cache.

Baruch
