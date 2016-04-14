From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Thu, 14 Apr 2016 14:50:28 +0800
Message-ID: <570F3DB4.1050408@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbcDNGud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 02:50:33 -0400
In-Reply-To: <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/13/2016 05:04 PM, Paolo Abeni wrote:
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

Acked-by: Jason Wang <jasowang@redhat.com>
