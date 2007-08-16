From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 10:08:51 +0800
Message-ID: <20070816020851.GA30809@gondor.apana.org.au>
References: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <20070816005348.GA9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com> <20070816011414.GC9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2471 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760627AbXHPCJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 22:09:51 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 07:45:44AM +0530, Satyam Sharma wrote:
>
> Completely agreed, again. To summarize again (had done so about ~100 mails
> earlier in this thread too :-) ...
> 
> atomic_{read,set}_volatile() -- guarantees volatility also along with
> atomicity (the two _are_ different concepts after all, irrespective of
> whether callsites normally want one with the other or not)
> 
> atomic_{read,set}_nonvolatile() -- only guarantees atomicity, compiler
> free to elid / coalesce / optimize such accesses, can keep the object
> in question cached in a local register, leads to smaller text, etc.
> 
> As to which one should be the default atomic_read() is a question of
> whether majority of callsites (more weightage to important / hot
> codepaths, lesser to obscure callsites) want a particular behaviour.
> 
> Do we have a consensus here? (hoping against hope, probably :-)

I can certainly agree with this.

But I have to say that I still don't know of a single place
where one would actually use the volatile variant.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
