From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net/core/dev.c : Race condition in net_tx_action.
Date: Wed, 25 Feb 2015 13:47:43 -0500 (EST)
Message-ID: <20150225.134743.267148874428657838.davem@davemloft.net>
References: <1424886659-3641-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ameenali023@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424886659-3641-1-git-send-email-ameenali023@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ameen Ali <ameenali023@gmail.com>
Date: Wed, 25 Feb 2015 19:50:59 +0200

> @@ -3413,7 +3413,7 @@ EXPORT_SYMBOL(netif_rx_ni);
>  
>  static void net_tx_action(struct softirq_action *h)
>  {
> -	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
> +	volatile struct softnet_data *sd = &__get_cpu_var(softnet_data);

volatile is never an appropriate solution to a race condition
