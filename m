From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 22:07:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919120730.GA6005@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <20040919120249.GA5963@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 10:02:49PM +1000, herbert wrote:
> 
> Another reason why this is bogus.
> 
> Most kernel users of unicast have a send timeout setting of 0.  Therefore
> your wake_up_process() call will never happen when netlink_attachskb is
> called by the kernel.

In fact this is the reason why this whole problem is non-existant.

Unless there is a kernel user that sends netlink messages with a timeout
value other than 0, this patch does not resolve any dead-locks at all
since there is none to start with.  The reason is that the kernel will
simply drop the message when the destination socket queue is full.

So it looks to me as if this entire patch is simply papering over bugs
in the user-space application where it either isn't processing the
messages fast enough or it needs to enlarge its queue size.

Here is a tip, use separate sockets for unicast and multicast messages.
That way your unicast socket is very unlikely to overrun.

So I'd like to see the whole thing reverted.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
