From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [patch] netfilter: potential NULL dereference in get_inner_hdr()
Date: Mon, 14 May 2012 09:36:55 +0200
Message-ID: <201205140936.56960.hans.schillstrom@ericsson.com>
References: <20120512110003.GB19472@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120512110003.GB19472@elgon.mountain>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 12 May 2012 13:00:03 Dan Carpenter wrote:
> There is a typo in the error checking and "&&" was used instead of "||".
> If skb_header_pointer() returns NULL then it leads to a NULL
> dereference.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Ack-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
 
> ---
> Btw, this is new code and Sparse complains about endian bugs.

Can you give me some hints here, arch , compiler version etc.
I guess it was input to hmark_addr_mask() that complains ?

> 
> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
> index 32fbd73..5817d03 100644
> --- a/net/netfilter/xt_HMARK.c
> +++ b/net/netfilter/xt_HMARK.c
> @@ -223,7 +223,7 @@ static int get_inner_hdr(const struct sk_buff *skb, int iphsz, int *nhoff)
>  
>  	/* Not enough header? */
>  	icmph = skb_header_pointer(skb, *nhoff + iphsz, sizeof(_ih), &_ih);
> -	if (icmph == NULL && icmph->type > NR_ICMP_TYPES)
> +	if (icmph == NULL || icmph->type > NR_ICMP_TYPES)
>  		return 0;
>  
>  	/* Error message? */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
