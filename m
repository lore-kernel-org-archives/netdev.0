From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 24 Sep 2004 10:12:25 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924001225.GA5051@gondor.apana.org.au>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <E1CAdCy-0001FM-00@gondolin.me.apana.org.au> <20040923164149.5368d291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040923164149.5368d291.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 04:41:49PM -0700, David S. Miller wrote:
> 
> Previously we counted TSO frames as single "packets" as long as
> we could fit one more frame into the congestion window we'd spit
> out the whole TSO frame, and this kept the pipe full.

I see.  In that case what we've got now can't possibly work.

How about this? We always to treat TSO frames as one packet.  We
continue to obey the congestion window by starting with a TSO MSS
that is small enough.  We increase the TSO MSS as the congestion
window goes up.

That should work, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
