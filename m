From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Give skb_checksum_help an sk_buff * again
Date: Mon, 25 Oct 2004 16:26:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025162606.5938f8df.davem@davemloft.net>
References: <20041025123507.GA4346@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041025123507.GA4346@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Oct 2004 22:35:07 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Since skb_checksum_help has been using pskb_expand_head for a while
> now without any ill effects, I thought it would be a good idea to
> remove the double pointers from it and its callers.
> 
> This is what the following patch does.  The only "rider" bit is the
> removal of an unnecessary BUG_ON in ip6_pkt_discard_out.  The preceding
> assignment was only added because the following function oopsed so
> there is no point in doing BUG_ON.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks great, patch applied.

It looks like this makes a few netfilter paths no longer
need a **pskb anymore as well.  Folks can feel free to make
that simplification. :-)

Thanks Herbert.
