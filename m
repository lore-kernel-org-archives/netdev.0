From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/7] net: refactor __netif_receive_skb_core
Date: Fri, 10 Apr 2015 12:56:29 -0700
Message-ID: <55282AED.1050306@gmail.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org> <1428668142-4006-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428668142-4006-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2015 05:15 AM, Pablo Neira Ayuso wrote:
> +another_round:
> +	ret = __netif_receive_skb_ingress(skb, pfmemalloc, orig_dev);
> +	switch (ret) {
> +	case NET_RX_SUCCESS:
> +	case NET_RX_DROP:
> +		break;
> +	case __NET_RX_ANOTHER_ROUND:
> +		goto another_round;
> +	}
>  	rcu_read_unlock();
> +
>  	return ret;
>  }
>  
> 

Couldn't this just be done as a do while?  It would probably be easier
to read and there wouldn't be any need for the another_round label anymore.

- Alex
