From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Thu, 2 Sep 2004 15:08:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902150830.6585cfc5.davem@redhat.com>
References: <4137681D.3000902@trash.net>
	<20040902144436.2c8c1337.davem@redhat.com>
	<20040902220343.GA3250@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040902220343.GA3250@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2004 08:03:44 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> That could also tie into another optimisation.  But it's
> an ugly one :) The sk->csum values are added up at the end of
> the processing so when we move bytes to and fro the total csum
> value stays the same even if the fragment csum values change.
> 
> Therefore we can get rid of the csum adjustments except for the
> parity bit in the getfrag call.
> 
> Is this an acceptable optimisation to you guys?

I have no problems with this.

> Another thing we can do is to not always fill up the frags in the middle
> and then move bytes off them.  As it is if you do a send that spans
> multiple packets each fragment will be filled up to the full and then
> chopped off when the next one is started.

Please elaborate.

> And to finish it off, here is a really trivial patch to shave off 27
> bytes from the source code :) It does nothing else, well unless your
> compiler decides to compile csum_block_sub out-of-line.

Applied :-)
