From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Mon, 13 Aug 2007 13:15:52 +0800
Message-ID: <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au>
References: <20070811042943.GA13410@linux.vnet.ibm.com>
Cc: herbert@gondor.apana.org.au, csnook@redhat.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935682AbXHMFRY@vger.kernel.org>
In-Reply-To: <20070811042943.GA13410@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> On Sat, Aug 11, 2007 at 08:54:46AM +0800, Herbert Xu wrote:
>> Chris Snook <csnook@redhat.com> wrote:
>> > 
>> > cpu_relax() contains a barrier, so it should do the right thing.  For 
>> > non-smp architectures, I'm concerned about interacting with interrupt 
>> > handlers.  Some drivers do use atomic_* operations.
>> 
>> What problems with interrupt handlers? Access to int/long must
>> be atomic or we're in big trouble anyway.
> 
> Reordering due to compiler optimizations.  CPU reordering does not
> affect interactions with interrupt handlers on a given CPU, but
> reordering due to compiler code-movement optimization does.  Since
> volatile can in some cases suppress code-movement optimizations,
> it can affect interactions with interrupt handlers.

If such reordering matters, then you should use one of the
*mb macros or barrier() rather than relying on possibly
hidden volatile cast.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
