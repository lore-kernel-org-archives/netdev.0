From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 11:53:42 +0800
Message-ID: <20070817035342.GA14744@gondor.apana.org.au>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <18117.1287.779351.836552@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org> <18117.6495.397597.582736@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	Satyam Sharma <satyam@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4872 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752821AbXHQDzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 23:55:18 -0400
Content-Disposition: inline
In-Reply-To: <18117.6495.397597.582736@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2007 at 01:43:27PM +1000, Paul Mackerras wrote:
>
> The cost of doing so seems to me to be well down in the noise - 44
> bytes of extra kernel text on a ppc64 G5 config, and I don't believe
> the extra few cycles for the occasional extra load would be measurable
> (they should all hit in the L1 dcache).  I don't mind if x86[-64] have
> atomic_read/set be nonvolatile and find all the missing barriers, but
> for now on powerpc, I think that not having to find those missing
> barriers is worth the 0.00076% increase in kernel text size.

BTW, the sort of missing barriers that triggered this thread
aren't that subtle.  It'll result in a simple lock-up if the
loop condition holds upon entry.  At which point it's fairly
straightforward to find the culprit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
