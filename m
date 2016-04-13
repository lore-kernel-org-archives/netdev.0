From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 05:52:25 -0700
Message-ID: <1460551945.10638.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460393493.git.pabeni@redhat.com>
	 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35203 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760486AbcDMMw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 08:52:27 -0400
Received: by mail-pf0-f176.google.com with SMTP id n1so33754779pfn.2
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 05:52:27 -0700 (PDT)
In-Reply-To: <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 11:04 +0200, Paolo Abeni wrote:
> The current tun_net_xmit() implementation don't need any external
> lock since it relay on rcu protection for the tun data structure
> and on socket queue lock for skb queuing.
> 
> This patch set the NETIF_F_LLTX feature bit in the tun device, so
> that on xmit, in absence of qdisc, no serialization lock is acquired
> by the caller.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
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

Acked-by: Eric Dumazet <edumazet@google.com>
