From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Fri, 19 Mar 2004 22:07:19 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319110719.GB29066@gondor.apana.org.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF0E.3050708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4059CF0E.3050708@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 18, 2004 at 05:32:14PM +0100, Patrick McHardy wrote:
>
> diff -Nru a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> --- a/net/ipv4/ip_input.c	Thu Mar 18 16:45:35 2004
> +++ b/net/ipv4/ip_input.c	Thu Mar 18 16:45:35 2004
> @@ -224,6 +224,12 @@
>  	resubmit:
>  		hash = protocol & (MAX_INET_PROTOS - 1);
>  		raw_sk = sk_head(&raw_v4_htable[hash]);
> +		ipprot = inet_protos[hash];
> +		smp_read_barrier_depends();
> +
> +		if (skb->sp && !ipprot->xfrm_prot)
> +			if (nf_postxfrm_input(skb))
> +				goto out;

Need to check ipprot != NULL here.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
