From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: pskb_expand_head instead of skb_copy in skb_checksum_help
Date: Tue, 24 Aug 2004 17:17:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824171709.57a613bd.davem@redhat.com>
References: <20040824110532.GA10241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040824110532.GA10241@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 21:05:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is the patch that you wanted to shoot holes at :)
> 
> The idea is simple.  None of the callers of skb_checksum are passing it
> skb's which are shared.  They may be cloned however.  But the application
> checksum is always in the skb header so there is no need to linearise it.
> 
> Supposing all these assumptions are correct, then we can avoid the overhead
> of skb_copy() and get away with pskb_expand_head().

I'm going to apply this.

If your assertion is wrong, then the skb_shared() BUG() will trigger
in pskb_expand_head() and we will know :-)
