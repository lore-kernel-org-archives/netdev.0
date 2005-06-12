From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 23:33:49 +1000
Message-ID: <20050612133349.GA6279__43842.4617554576$1118583138$gmane$org@gondor.apana.org.au>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au> <20050612083409.GA8220@alpha.home.local> <20050612103020.GA25111@gondor.apana.org.au> <20050612114039.GI28759@alpha.home.local> <20050612120627.GA5858@gondor.apana.org.au> <20050612123253.GK28759@alpha.home.local> <20050612131323.GA10188@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
Content-Disposition: inline
In-Reply-To: <20050612131323.GA10188@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 11:13:23PM +1000, herbert wrote:
> On Sun, Jun 12, 2005 at 02:32:53PM +0200, Willy Tarreau wrote:
> >
> > but it's not the case (although the naming is not clear). So if the remote
> > end was the one which sent the SYN-ACK, it will clear its session. If it has
> > been spoofed, it will ignore the RST because in turn, the SEQ will not be
> > within its window.
> 
> This is what should happen:

Sorry, you're right.  The SEQ check should catch this.

However, a few lines down in that same function there is a th->rst
check which will kill the connection just as effectively.

My point is that there are many ways to kill TCP connections in ways
similar to what you proposed initially so it isn't that special.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
