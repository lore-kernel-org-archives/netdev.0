From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 07:59:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919215915.GB9573@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414DF11C.1080505@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 10:50:36PM +0200, Pablo Neira wrote:
>
> >Another reason why this is bogus.
> >
> >Most kernel users of unicast have a send timeout setting of 0.  Therefore
> >your wake_up_process() call will never happen when netlink_attachskb is
> >called by the kernel.
> 
> Yes, I didn't modify MSG_DONTWAIT + unicast behaviour and I've never 
> wanted to. Actually my patch is not addressed to that case, my intention 

I think this discussion might as well end here, we're obviously not
communicating at all.

I'm not talking about MSG_DONTWAIT, I'm talking about kernel netlink
message senders.  They never wait for obvious reasons.

> Which are those applications? for example, netfilter modules like 
> ip_queue and ipt_ULOG. Even more, these applications are in interrupt 
> context and, if I'm not wrong, I realized that there's some problems 
> using netlink sockets in this context, for example, see netlink_ack 
> allocating a skb with GFP_KERNEL flag, it hits a bug slab.

Well please define your problem more accurately.  A test-case would help.

I'd like to see the original patch reverted.  We can then sit down and work
out what the real problem is (if any).

> >Worse still, previously if a netlink request blocked indefinitely it
> >only did that in the context of the calling process.  Now it'll
> >dead-lock the entire system because you're using the generic work
> >queue.
>
> Hebert, I don't see such case, please could you detail it a bit more?

As it is since the kernel processing is done in the context of the calling
process, it is allowed to sleep indefinitely (semaphore contention, etc.).

Now that you've put it into keventd, sleeping indefinitely will lock up
the system.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
