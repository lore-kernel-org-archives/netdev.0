From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 12:50:48 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927025048.GA6723@gondor.apana.org.au>
References: <20040923164149.5368d291.davem@davemloft.net> <E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 11:27:24AM +1000, Herbert Xu wrote:
> 
> Indeed, I think the new code means that Minshall's check will disable
> Nagle which is what was keeping TSO working properly.
> 
> Anton, could you please try this patch which disables Minshall's check
> and see what it does?

Never mind.  Minshall is innocent :)

We set the maximum TSO factor bounded by the congestion window.  But
when the congestion window is raised, we don't call tcp_sync_mss
which is the only place that can raise the TSO factor.

So the TSO factor never grows above what we start with.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
