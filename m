From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 15:45:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927054541.GA8858@gondor.apana.org.au>
References: <20040923164149.5368d291.davem@davemloft.net> <E1CBkIW-0001dF-00@gondolin.me.apana.org.au> <20040927025048.GA6723@gondor.apana.org.au> <20040926210029.22750d47.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040926210029.22750d47.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 26, 2004 at 09:00:29PM -0700, David S. Miller wrote:
> 
> The very next time we check to see if we can
> make forward progress on the send queue we'll call tcp_current_mss()
> which causes the right things to happen.

tcp_current_mss() doesn't call tcp_sync_mss() unless the PMTU changes.

> Something else is wrong.  I think part of it is that we need to
> make tcp_clean_rtx_queue() return FLAG_DATA_ACKED even when a
> partial TSO packet is ACK'd by the other end.  This will make
> RTO etc. calculations actually occur, among other things.  But
> I have no idea if that will clear up the performance problems
> TSO is having with the new code.

There probably is something else wrong, since this should only limit
the TSO size.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
