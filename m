From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 3/7] tcp: harmonize tcp_vx_rcv header length
 assumptions
Date: Wed, 17 Feb 2010 15:47:34 -0800 (PST)
Message-ID: <20100217.154734.177239957.davem@davemloft.net>
References: <4B7791CF.9030201@gmail.com>
	<4B77953C.7070908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, andi@firstfloor.org
To: william.allen.simpson@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B77953C.7070908@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sun, 14 Feb 2010 01:16:28 -0500

> @@ -1559,7 +1559,8 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
>  		return 0;
>  	}
>  
> -	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
> +	/* Assumes header and options unchanged since checksum_init() */
> +	if (tcp_checksum_complete(skb))
>  		goto csum_err;
>  

Not true.

The skb->len can be modified by the call to sk_filter() done
by tcp_v4_rcv().
