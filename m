From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback:Make the function xenvif_schedulable have  a
 return type of bool
Date: Wed, 17 Jun 2015 12:10:46 +0100
Message-ID: <20150617111046.GG1813@zion.uk.xensource.com>
References: <1434510210-1341-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434510210-1341-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 16, 2015 at 11:03:30PM -0400, Nicholas Krause wrote:
> This makes the function xenvif_sechedulable have a return type of
> bool now due to this particular function's return statement only
> ever evaluating to have a value of one or zero.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/common.h    | 2 +-
>  drivers/net/xen-netback/interface.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 8a495b3..c02cafb 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -280,7 +280,7 @@ void xenvif_free(struct xenvif *vif);
>  int xenvif_xenbus_init(void);
>  void xenvif_xenbus_fini(void);
>  
> -int xenvif_schedulable(struct xenvif *vif);
> +bool xenvif_schedulable(struct xenvif *vif);
>  
>  int xenvif_queue_stopped(struct xenvif_queue *queue);
>  void xenvif_wake_queue(struct xenvif_queue *queue);
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 1a83e19..b5fcb52 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -63,7 +63,7 @@ void xenvif_skb_zerocopy_complete(struct xenvif_queue *queue)
>  	atomic_dec(&queue->inflight_packets);
>  }
>  
> -int xenvif_schedulable(struct xenvif *vif)
> +bool xenvif_schedulable(struct xenvif *vif)
>  {
>  	return netif_running(vif->dev) &&
>  		test_bit(VIF_STATUS_CONNECTED, &vif->status) &&
> -- 
> 2.1.4
