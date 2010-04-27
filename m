From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 15:36:56 -0700
Message-ID: <20100427153656.7bcaba83@nehalam>
References: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60008 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757358Ab0D0WhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 18:37:10 -0400
In-Reply-To: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Apr 2010 15:20:25 -0700
Dimitris Michailidis <dm@chelsio.com> wrote:

> Implement the ->set_flags ethtool method to control NETIF_F_RXHASH and
> set skb->rxhash to the HW calculated hash accordingly.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
> ---
>  drivers/net/cxgb4/cxgb4_main.c |   15 ++++++++++++++-
>  drivers/net/cxgb4/sge.c        |    7 ++++++-
>  drivers/net/cxgb4/t4_msg.h     |    1 +
>  3 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
> index 5f582db..1bad500 100644
> --- a/drivers/net/cxgb4/cxgb4_main.c
> +++ b/drivers/net/cxgb4/cxgb4_main.c
> @@ -1711,6 +1711,18 @@ static int set_tso(struct net_device *dev, u32 value)
>  	return 0;
>  }
>  
> +static int set_flags(struct net_device *dev, u32 flags)
> +{
> +	if (flags & ~ETH_FLAG_RXHASH)
> +		return -EOPNOTSUPP;
> +
> +	if (flags & ETH_FLAG_RXHASH)
> +		dev->features |= NETIF_F_RXHASH;
> +	else
> +		dev->features &= ~NETIF_F_RXHASH;
> +	return 0;
> +}

You need to check for and reject other values NTUPLE and LRO
