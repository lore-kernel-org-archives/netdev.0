From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] tun: don't require serialization lock on tx
Date: Sun, 17 Apr 2016 13:20:45 +0300
Message-ID: <20160417132004-mutt-send-email-mst@redhat.com>
References: <cc7ac4631f0a32c4d61b73f4f28b52a05ab8651d.1460651429.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbcDQKUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2016 06:20:50 -0400
Content-Disposition: inline
In-Reply-To: <cc7ac4631f0a32c4d61b73f4f28b52a05ab8651d.1460651429.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 06:39:39PM +0200, Paolo Abeni wrote:
> The current tun_net_xmit() implementation don't need any external
> lock since it relies on rcu protection for the tun data structure
> and on socket queue lock for skb queuing.
> 
> This patch set the NETIF_F_LLTX feature bit in the tun device, so
> that on xmit, in absence of qdisc, no serialization lock is acquired
> by the caller.
> 
> The user space can remove the default tun qdisc with:
> 
> tc qdisc replace dev <tun device name> root noqueue
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Eric Dumazet <edumazet@google.com>

This one seems transparent to userspace so:

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> 
> ---
> RFC -> v1
>  - fixed a commit message typo, extended the comment with a 
>    configuration hint
> ---
>  drivers/net/tun.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index faf9297..42992dc 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1796,7 +1796,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
>  				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
>  				   NETIF_F_HW_VLAN_STAG_TX;
> -		dev->features = dev->hw_features;
> +		dev->features = dev->hw_features | NETIF_F_LLTX;
>  		dev->vlan_features = dev->features &
>  				     ~(NETIF_F_HW_VLAN_CTAG_TX |
>  				       NETIF_F_HW_VLAN_STAG_TX);
> -- 
> 1.8.3.1
