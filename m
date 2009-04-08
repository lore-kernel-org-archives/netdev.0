From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 8 Apr 2009 16:09:48 -0700
Message-ID: <20090408160948.2257d311@s6510>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47609 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756193AbZDHXKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 19:10:43 -0400
In-Reply-To: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Apr 2009 15:48:12 -0700
Tom Herbert <therbert@google.com> wrote:

> -extern int		netif_receive_skb(struct sk_buff *skb);
> +extern int            __netif_receive_skb(struct sk_buff *skb);
> +
> +static inline int netif_receive_skb(struct sk_buff *skb)
> +{
> +#ifdef CONFIG_NET_SOFTRPS
> +	return netif_rx(skb);
> +#else
> +	return __netif_receive_skb(skb);
> +#endif
> +}

Ugh, this forces all devices receiving back into a single backlog
queue.
