From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen-netback: fix extra_info handling in
 xenvif_tx_err()
Date: Thu, 12 May 2016 15:15:33 +0100
Message-ID: <20160512141533.GL8063@citrix.com>
References: <1463060583-7524-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56271 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901AbcELOPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 10:15:40 -0400
Content-Disposition: inline
In-Reply-To: <1463060583-7524-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 02:43:03PM +0100, Paul Durrant wrote:
> Patch 562abd39 "xen-netback: support multiple extra info fragments
> passed from frontend" contained a mistake which can result in an in-
> correct number of responses being generated when handling errors
> encountered when processing packets containing extra info fragments.
> This patch fixes the problem.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Reported-by: Jan Beulich <JBeulich@suse.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index b42f260..4412a57 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -711,6 +711,7 @@ static void xenvif_tx_err(struct xenvif_queue *queue,
>  		if (cons == end)
>  			break;
>  		RING_COPY_REQUEST(&queue->tx, cons++, txp);
> +		extra_count = 0; /* only the first frag can have extras */
>  	} while (1);
>  	queue->tx.req_cons = cons;
>  }
> -- 
> 2.1.4
> 
