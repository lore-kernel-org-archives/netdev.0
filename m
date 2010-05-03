From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ppp_generic: pull 2 bytes so that PPP_PROTO(skb)
 is valid
Date: Sun, 02 May 2010 23:25:20 -0700 (PDT)
Message-ID: <20100502.232520.146109082.davem@davemloft.net>
References: <4BDB244D.40800@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4BDB244D.40800@simon.arlott.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Fri, 30 Apr 2010 19:41:17 +0100

> @@ -1572,8 +1572,18 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
>  		return;
>  	}
>  
> -	proto = PPP_PROTO(skb);
> +
>  	read_lock_bh(&pch->upl);
> +	if (!pskb_may_pull(skb, 2)) {
> +		kfree_skb(skb);
> +		if (pch->ppp) {
> +			++pch->ppp->dev->stats.rx_length_errors;
> +			ppp_receive_error(pch->ppp);
> +		}
> +		goto done;
> +	}
> +
> +	proto = PPP_PROTO(skb);

This makes the skb->len == 0 test at the beginning completely redundant.

Put your pskb_may_pull(skb, 2) call there and remove the skb->len==0
check entirely.
