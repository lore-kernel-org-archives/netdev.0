From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Wed, 8 Sep 2004 09:15:57 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907231557.GA2254@gondor.apana.org.au>
References: <4137681D.3000902@trash.net> <20040902144436.2c8c1337.davem@redhat.com> <20040902220343.GA3250@gondor.apana.org.au> <20040903.104050.29603454.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040903.104050.29603454.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 03, 2004 at 10:40:50AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> @@ -1026,18 +1033,22 @@
>  
>  	while (size > 0) {
>  		int i;
> -		if ((len = mtu - skb->len) <= 0) {
> +
> +		/* Check if the remaining data fits into current packet. */
> +		len = mtu - skb->len;
> +		if (len > size)
> +			len = maxfraglen - skb->len;

I think that should be len < size, right?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
