From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 02:27:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202022733.43cf693e.davem@redhat.com>
References: <20031201201651.GA20194@gondor.apana.org.au>
	<20031201204700.GA20349@gondor.apana.org.au>
	<20031201135154.6906454c.davem@redhat.com>
	<20031201220509.GA20827@gondor.apana.org.au>
	<20031201142131.5da50a07.davem@redhat.com>
	<20031201152215.522c2447.davem@redhat.com>
	<20031202101025.GA25422@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031202101025.GA25422@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 21:10:25 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> My problem turns out to be that oif != 0 for the outgoing packets.
> Since frag_needed only handle cache entries where oif == 0 it
> never has a chance to work.
> 
> The application that generated these packets is the RPC code in glibc.

That behavior of glibc is incorrect, I know about it, and I explained
all this to Uli Drepper some time ago and he fixed it.

Current glibc should not be doing this.  If it still is, since Uli
understood my arguments, it probably just slipped under the rug.
Tell me this so I can take care of it.

What the glibc code was doing was mirroring the input packet parameters
(saddr/daddr/if/etc.) into what it used for the output packet sends.
