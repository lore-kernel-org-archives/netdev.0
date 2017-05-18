From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 3/3] virtio-net: enable TSO/checksum offloads for
 Q-in-Q vlans
Date: Thu, 18 May 2017 18:06:35 +0300
Message-ID: <20170518180630-mutt-send-email-mst@kernel.org>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40102 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932227AbdERPGh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:06:37 -0400
Content-Disposition: inline
In-Reply-To: <1495114265-23368-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 09:31:05AM -0400, Vladislav Yasevich wrote:
> Since virtio does not provide it's own ndo_features_check handler,
> TSO, and now checksum offload, are disabled for stacked vlans.
> Re-enable the support and let the host take care of it.  This
> restores/improves Guest-to-Guest performance over Q-in-Q vlans.
> 
> CC: "Michael S. Tsirkin" <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: virtualization@lists.linux-foundation.org
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 8324a5e..341fb96 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -2028,6 +2028,7 @@ static const struct net_device_ops virtnet_netdev = {
>  	.ndo_poll_controller = virtnet_netpoll,
>  #endif
>  	.ndo_xdp		= virtnet_xdp,
> +	.ndo_features_check	= passthru_features_check,
>  };
>  
>  static void virtnet_config_changed_work(struct work_struct *work)
> -- 
> 2.7.4
