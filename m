From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/7] net: dsa: remove useless rcv copy in DSA
 tree
Date: Tue, 30 May 2017 17:05:31 +0200
Message-ID: <20170530150531.GD22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
 <20170530142131.23568-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58278 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751507AbdE3PFe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 11:05:34 -0400
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 10:21:26AM -0400, Vivien Didelot wrote:
> The dsa_switch_tree holds a copy of the rcv member of the dsa_device_ops
> structure. dst->rcv is always assigned to dst->tag_ops->rcv. Remove this
> useless copy.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h | 4 ----
>  net/dsa/dsa.c     | 4 ++--
>  net/dsa/dsa2.c    | 2 --
>  net/dsa/legacy.c  | 2 --
>  4 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index cb5d668b265d..4b82766715e9 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -126,10 +126,6 @@ struct dsa_switch_tree {
>  	 * protocol to use.
>  	 */
>  	struct net_device	*master_netdev;
> -	struct sk_buff *	(*rcv)(struct sk_buff *skb,
> -				       struct net_device *dev,
> -				       struct packet_type *pt,
> -				       struct net_device *orig_dev);
>  
>  	/*
>  	 * Original copy of the master netdev ethtool_ops
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 7a8a0358299b..861dc0e5020d 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -29,7 +29,7 @@
>  
>  bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
>  {
> -	return !!dst->rcv;
> +	return dst->tag_ops && dst->tag_ops->rcv;

This makes the hot path more expensive. The copy is probably worth it
in terms of performance.

   Andrew
