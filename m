From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 3/5] ixgbe: Add support for ndo_ll_poll
Date: Wed, 27 Feb 2013 10:41:42 -0800
Message-ID: <1361990502.15793.0.camel@edumazet-glaptop>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	 <20130227175606.10611.55498.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175606.10611.55498.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-27 at 09:56 -0800, Eliezer Tamir wrote:

> @@ -1458,7 +1459,9 @@ static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
>  {
>  	struct ixgbe_adapter *adapter = q_vector->adapter;
>  
> -	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
> +	if (ixgbe_qv_ll_polling(q_vector))
> +		netif_receive_skb(skb);
> +	else if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
>  		napi_gro_receive(&q_vector->napi, skb);
>  	else
>  		netif_rx(skb);

Interesting reordering issue here.

Why by-passing GRO stack if its enabled ?
