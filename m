From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 12:31:34 +1100
Message-ID: <E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
References: <20050124005348.GL23931@postel.suug.ch>
Cc: kaber@trash.net, david@davidcoulson.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20050124005348.GL23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
> Call Trace:
>  [<c02b7c86>] dev_queue_xmit+0x246/0x290
...
>  [<c02e79c0>] ip_finish_output+0x0/0x1f0
>  [<c02e65d0>] ip_forward_finish+0x0/0x50

Something is screwed up here.  If the packet really went
through forwarding, then skb->ip_summed should be CHECKSUM_NONE.
This is done as the first thing in ip_forward().

So if you're seeing CHECKSUM_HW at the end of the pipe,
then somebody must've changed it.  CHECKSUM_HW should
only be seen in dev_queue_xmit for locally generated
traffic.

I suggest that you print out the value of skb->ip_summed
at various points in and after ip_forward() to find out
who is changing skb->ip_summed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
