From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 2/2] tun: don't set a default qdisc
Date: Wed, 13 Apr 2016 13:26:51 +0300
Message-ID: <20160413132411-mutt-send-email-mst@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <1a216fb6cade7dcd7d2c1d4ce113a1ee6e3fdeb6.1460393493.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965432AbcDMK0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 06:26:55 -0400
Content-Disposition: inline
In-Reply-To: <1a216fb6cade7dcd7d2c1d4ce113a1ee6e3fdeb6.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 11:04:47AM +0200, Paolo Abeni wrote:
> This patch disables the default qdisc by explicitly setting the
> IFF_NO_QUEUE private flag so that now the tun xmit path do not
> require any lock by default.
> 
> The default qdisc was first removed as a side effect of commit
> f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
> and recently restored with commit 016adb7260f4 ("tuntap: restore default qdisc")
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

I wonder about this back and forth.
Jason, do you see a workload where the default qdisc
is preferable?

> ---
>  drivers/net/tun.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 42992dc..0a0b63c 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1081,6 +1081,7 @@ static void tun_net_init(struct net_device *dev)
>  
>  		break;
>  	}
> +	dev->priv_flags |= IFF_NO_QUEUE;
>  }
>  
>  /* Character device part */
> -- 
> 1.8.3.1
