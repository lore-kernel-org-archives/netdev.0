From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next 1/2] xen-netback: remove redundent parameter in
 netbk_count_requests
Date: Wed, 1 May 2013 11:10:22 +0100
Message-ID: <1367403022.3142.675.camel@zakaz.uk.xensource.com>
References: <1367340644-19690-1-git-send-email-wei.liu2@citrix.com>
	 <1367340644-19690-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:60178 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759509Ab3EAKKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 06:10:24 -0400
In-Reply-To: <1367340644-19690-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 17:50 +0100, Wei Liu wrote:
> Tracking down from the caller, first_idx is always equal to vif->tx.req_cons.
> Remove it to avoid confusion.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index a2865f1..c44772d 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -928,7 +928,6 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
>  
>  static int netbk_count_requests(struct xenvif *vif,
>  				struct xen_netif_tx_request *first,
> -				RING_IDX first_idx,
>  				struct xen_netif_tx_request *txp,
>  				int work_to_do)
>  {
> @@ -1005,7 +1004,7 @@ static int netbk_count_requests(struct xenvif *vif,
>  	} while ((txp++)->flags & XEN_NETTXF_more_data);
>  
>  	if (drop_err) {
> -		netbk_tx_err(vif, first, first_idx + slots);
> +		netbk_tx_err(vif, first, cons + slots);
>  		return drop_err;
>  	}
>  
> @@ -1470,8 +1469,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>  				continue;
>  		}
>  
> -		ret = netbk_count_requests(vif, &txreq, idx,
> -					   txfrags, work_to_do);
> +		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
>  		if (unlikely(ret < 0))
>  			continue;
>  
