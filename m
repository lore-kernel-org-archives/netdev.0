From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v3 2/2] xen-netback: napi: don't prematurely request
 a tx event
Date: Wed, 11 Dec 2013 09:44:15 +0000
Message-ID: <1386755055.30271.2.camel@kazak.uk.xensource.com>
References: <1386682782-7052-1-git-send-email-paul.durrant@citrix.com>
	 <1386682782-7052-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:45395 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab3LKJoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 04:44:18 -0500
In-Reply-To: <1386682782-7052-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 13:39 +0000, Paul Durrant wrote:
> This patch changes the RING_FINAL_CHECK_FOR_REQUESTS in
> xenvif_build_tx_gops to a check for RING_HAS_UNCONSUMED_REQUESTS as the
> former call has the side effect of advancing the ring event pointer and
> therefore inviting another interrupt from the frontend before the napi
> poll has actually finished, thereby defeating the point of napi.

Like I said last time:

Can you add a reminder of when/where the ring event pointer is
eventually advanced now please.

> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 83b4e5b..fb512a9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1381,7 +1381,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
>  			continue;
>  		}
>  
> -		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
> +		work_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
>  		if (!work_to_do)
>  			break;
>  
