From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 22:31:06 +1100
Message-ID: <20050228113106.GA3268@gondor.apana.org.au>
References: <20050224155906.73890361@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, mostrows@speakeasy.net,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050224155906.73890361@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 24, 2005 at 11:59:06PM +0000, Stephen Hemminger wrote:
> 
> Not sure if this is correct, but shouldn't pppoe be doing the following:
> -----
> diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> --- a/drivers/net/pppoe.c	2005-02-24 15:40:10 -08:00
> +++ b/drivers/net/pppoe.c	2005-02-24 15:40:10 -08:00
> @@ -339,6 +339,7 @@
>  		int len = ntohs(ph->length);
>  		skb_pull(skb, sizeof(struct pppoe_hdr));
>  		skb_trim(skb, len);
> +		skb->ip_summed = CHECKSUM_NONE;

This penalises CHECKSUM_HW.  We should have a generic helper
function that does the checksum folding for CHECKSUM_HW and
if otherwise set ip_summed to CHECKSUM_NONE.

In fact it looks like the current code in ip_gre is broken
in this respect as well.

Let me whip up a patch tomorrow.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
