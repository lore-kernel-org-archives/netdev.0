From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH net-next 1/2] xen-netback: remove redundent
 parameter in netbk_count_requests
Date: Thu, 02 May 2013 10:31:57 +0100
Message-ID: <51824EAD02000078000D281D@nat28.tlf.novell.com>
References: <1367340644-19690-1-git-send-email-wei.liu2@citrix.com>
 <1367340644-19690-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:33083 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163Ab3EBJbS convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Thu, 2 May 2013 05:31:18 -0400
In-Reply-To: <1367340644-19690-2-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 30.04.13 at 18:50, Wei Liu <wei.liu2@citrix.com> wrote:
> Tracking down from the caller, first_idx is always equal to vif->tx.req_cons.
> Remove it to avoid confusion.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Suggested-by: Jan Beulich <jbeulich@suse.com>

> ---
>  drivers/net/xen-netback/netback.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c 
> b/drivers/net/xen-netback/netback.c
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
> @@ -1470,8 +1469,7 @@ static unsigned xen_netbk_tx_build_gops(struct 
> xen_netbk *netbk)
>  				continue;
>  		}
>  
> -		ret = netbk_count_requests(vif, &txreq, idx,
> -					   txfrags, work_to_do);
> +		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
>  		if (unlikely(ret < 0))
>  			continue;
>  
> -- 
> 1.7.10.4
