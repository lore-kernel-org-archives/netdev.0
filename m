From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/4] xen-netfront: remove unused variable `extra'
Date: Mon, 18 Mar 2013 11:42:02 +0000
Message-ID: <1363606922.30193.21.camel@zakaz.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:33675 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3CRLmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 07:42:05 -0400
In-Reply-To: <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:

I think a few more words are needed here since from the code you are
removing it seems very much like gso is used for something. If you have
a proof that the "extra = gso" case is never hit then please explain it.
Perhaps a reference to the removal of the last user?

Or maybe it is the case that it should be used and the bug is that it
isn't?

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |    8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 7ffa43b..5527663 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -537,7 +537,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct netfront_info *np = netdev_priv(dev);
>  	struct netfront_stats *stats = this_cpu_ptr(np->stats);
>  	struct xen_netif_tx_request *tx;
> -	struct xen_netif_extra_info *extra;
>  	char *data = skb->data;
>  	RING_IDX i;
>  	grant_ref_t ref;
> @@ -581,7 +580,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	tx->gref = np->grant_tx_ref[id] = ref;
>  	tx->offset = offset;
>  	tx->size = len;
> -	extra = NULL;
>  
>  	tx->flags = 0;
>  	if (skb->ip_summed == CHECKSUM_PARTIAL)
> @@ -597,10 +595,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		gso = (struct xen_netif_extra_info *)
>  			RING_GET_REQUEST(&np->tx, ++i);
>  
> -		if (extra)
> -			extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
> -		else
> -			tx->flags |= XEN_NETTXF_extra_info;
> +		tx->flags |= XEN_NETTXF_extra_info;
>  
>  		gso->u.gso.size = skb_shinfo(skb)->gso_size;
>  		gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
> @@ -609,7 +604,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  		gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
>  		gso->flags = 0;
> -		extra = gso;
>  	}
>  
>  	np->tx.req_prod_pvt = i + 1;
