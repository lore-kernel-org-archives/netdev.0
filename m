From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Interdomain/interpartition communication without a checksum
Date: Wed, 25 May 2005 15:39:43 -0700 (PDT)
Message-ID: <20050525.153943.69020533.davem@davemloft.net>
References: <20050511183554.GA28298@us.ibm.com>
	<20050516.130737.77060495.davem@davemloft.net>
	<20050517163420.GA19251@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, niv@us.ibm.com, habanero@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <20050517163420.GA19251@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Tue, 17 May 2005 11:34:20 -0500

> --- ../xen-unstable-pristine/linux-2.6.11-xen0/include/linux/skbuff.h	2005-03-02 01:38:38.000000000 -0600
> +++ linux-2.6.11-xen0/include/linux/skbuff.h	2005-05-13 10:43:08.000000000 -0500
> @@ -37,6 +37,10 @@
>  #define CHECKSUM_HW 1
>  #define CHECKSUM_UNNECESSARY 2
>  
> +#define SKB_CLONED	1
> +#define SKB_NOHDR	2
> +#define SKB_FDW_NO_CSUM	4
> +


You create SKB_NOHDR yet do not make use of it to
replace skb->nohdr.

> @@ -603,7 +603,7 @@ int pskb_expand_head(struct sk_buff *skb
>  	skb->mac.raw += off;
>  	skb->h.raw   += off;
>  	skb->nh.raw  += off;
> -	skb->cloned   = 0;
> +	skb->flags    &= SKB_CLONED;
>  	atomic_set(&skb_shinfo(skb)->dataref, 1);
>  	return 0;

This does not clear SKB_CLONED, it makes it the only possible
bit set.  Clearly this was not your intention.
