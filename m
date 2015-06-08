From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: replace last open coded skb_orphan_frags
 with function call
Date: Mon, 8 Jun 2015 17:54:31 +0200
Message-ID: <20150608175416-mutt-send-email-mst@redhat.com>
References: <1433778788-16971-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052AbbFHPye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 11:54:34 -0400
Content-Disposition: inline
In-Reply-To: <1433778788-16971-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 08, 2015 at 11:53:08AM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Commit 70008aa50e92 ("skbuff: convert to skb_orphan_frags") replaced
> open coded tests of SKBTX_DEV_ZEROCOPY and skb_copy_ubufs with calls
> to helper function skb_orphan_frags. Apply that to the last remaining
> open coded site.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  net/core/dev.c | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0602e91..6778a99 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1723,15 +1723,8 @@ EXPORT_SYMBOL_GPL(is_skb_forwardable);
>  
>  int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
>  {
> -	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> -		if (skb_copy_ubufs(skb, GFP_ATOMIC)) {
> -			atomic_long_inc(&dev->rx_dropped);
> -			kfree_skb(skb);
> -			return NET_RX_DROP;
> -		}
> -	}
> -
> -	if (unlikely(!is_skb_forwardable(dev, skb))) {
> +	if (skb_orphan_frags(skb, GFP_ATOMIC) ||
> +	    unlikely(!is_skb_forwardable(dev, skb))) {
>  		atomic_long_inc(&dev->rx_dropped);
>  		kfree_skb(skb);
>  		return NET_RX_DROP;
> -- 
> 2.2.0.rc0.207.ga3a616c
