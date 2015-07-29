From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Wed, 29 Jul 2015 23:06:18 +0200
Message-ID: <20150729210618.GF32705@breakpoint.cc>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
 <1438203103-27013-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56091 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbbG2VGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 17:06:22 -0400
Content-Disposition: inline
In-Reply-To: <1438203103-27013-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Sutter <phil@nwl.cc> wrote:
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  net/Kconfig        | 12 ++++++++++++
>  net/ethernet/eth.c |  2 +-
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/net/Kconfig b/net/Kconfig
> index 7021c1b..21c164f 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -48,6 +48,18 @@ config COMPAT_NETLINK_MESSAGES
>  config NET_INGRESS
>  	bool
>  
> +config DEFAULT_TX_QUEUE_LEN
> +	prompt "Default TX queue length (in packets)" if EXPERT
> +	int
> +	default 1000	# Ethernet wants good queues
> +	help
> +	  Set the default value of tx_queue_len for newly created network
> +	  interfaces. It is used by queueing disciplines to determine how many
> +	  packets to keep in backlog before starting to drop new ones.
> +
> +	  The default value of 1000 packets is there for a very long time and
> +	  in combination with GSO way too big.
> +

I can't see how this could be used in a meaningful way.

No distro is going to touch this.

I don't think sysctl value would help either.
