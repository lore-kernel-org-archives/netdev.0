From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v3 06/13] sock: MSG_ZEROCOPY notification
 coalescing
Date: Thu, 22 Jun 2017 13:07:41 -0400 (EDT)
Message-ID: <20170622.130741.873016534812693988.davem@davemloft.net>
References: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
        <20170621211816.53837-7-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621211816.53837-7-willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 21 Jun 2017 17:18:09 -0400

> +static bool skb_zerocopy_notify_extend(struct sk_buff *skb, u32 lo, u16 len)
> +{
> +	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
> +	u64 sum_len;
> +	u32 old_lo, old_hi;

Reverse christmas tree.

>  void sock_zerocopy_callback(struct ubuf_info *uarg, bool success)
>  {
>  	struct sock_exterr_skb *serr;
> -	struct sk_buff *skb = skb_from_uarg(uarg);
> +	struct sk_buff *tail, *skb = skb_from_uarg(uarg);
>  	struct sock *sk = skb->sk;
> -	u16 id = uarg->desc;
> +	struct sk_buff_head *q = &sk->sk_error_queue;
> +	unsigned long flags;
> +	u32 lo, hi;
> +	u16 len;

Likewise.
