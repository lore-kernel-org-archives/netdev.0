From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix race in process_backlog
Date: Wed, 03 Oct 2007 14:58:07 -0700 (PDT)
Message-ID: <20071003.145807.111205634.davem@davemloft.net>
References: <1191426293.5599.27.camel@lappy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, jdike@addtoit.com
To: a.p.zijlstra@chello.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758768AbXJCV6Y@vger.kernel.org>
In-Reply-To: <1191426293.5599.27.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 03 Oct 2007 17:44:53 +0200

> Index: linux-2.6/net/core/dev.c
> ===================================================================
> --- linux-2.6.orig/net/core/dev.c
> +++ linux-2.6/net/core/dev.c
> @@ -2095,11 +2095,11 @@ static int process_backlog(struct napi_s
>  
>  		local_irq_disable();
>  		skb = __skb_dequeue(&queue->input_pkt_queue);
> -		local_irq_enable();
>  		if (!skb) {
> -			napi_complete(napi);
> +			__napi_complete(napi);
>  			break;
>  		}
> +		local_irq_enable();

What re-enables interrupts in the !skb path?
