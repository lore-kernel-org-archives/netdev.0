From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 09:31:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919233118.GB10124@gondor.apana.org.au>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au> <414DF05E.7020601@eurodev.net> <20040919212033.GA9254@gondor.apana.org.au> <414E04D6.5010106@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414E04D6.5010106@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 12:14:46AM +0200, Pablo Neira wrote:
> 
> When the buffer is full, I wake up the user process and put the kernel 
> thread to sleep to let the user process empty the queue.

Well that sounds like a good idea but it isn't:

1) You wake up no-one or the wrong process half of the time.
2) Every time a packet is added to the queue the destination process is
woken up.  So by the time it's full it has been woken up many times
already.  If all those wake_up's didn't make a difference, then this
extra one here isn't likely to either.
3) All kernel callers of this function have timeout set to zero.  Therefore
they won't even encounter your code.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
