From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sparc oops in ip_fast_csum
Date: Sun, 6 Jan 2008 15:14:30 +1100
Message-ID: <20080106041430.GA3784@gondor.apana.org.au>
References: <20080105094400.GH27894@ZenIV.linux.org.uk> <E1JBJHA-0000hy-00@gondolin.me.apana.org.au> <20080106020214.GQ27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: m.kozlowski@tuxland.pl, davem@davemloft.net,
	sparclinux@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4732 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753211AbYAFEOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 23:14:44 -0500
Content-Disposition: inline
In-Reply-To: <20080106020214.GQ27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2008 at 02:02:14AM +0000, Al Viro wrote:
> 
> E.g. what about ipt_REJECT.c::send_reset()?  Or myri10ge_get_frag_header()?

Yes both look wrong.

Patrick, please have a look at the former.  In fact it's not just
that ihl may be bogus (which might be harmless as long as the REJECT
hook only gets called from within the IP stack), I think REJECT would
also do the wrong thing if the packet had IP options.  So perhaps we
should just make it create a packet from scratch rather than being
too clever in reusing the old one.

As to LRO, I must say it was a pretty shoddy job.  Now I can't complain
too much because I wasn't able to spend any time in 2007 working on it.
But it's definitely high on my todo list for 2008.

Oh and Al, your effort in going through all the ip_fast_csum callers
is much appreciated!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
