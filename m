From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next 1/2 RESEND v3] net: use NETIF_F_ALL_TSO for vlan
 features
Date: Wed, 11 May 2011 09:35:07 -0700
Message-ID: <4DCABABB.9040001@chelsio.com>
References: <4DCA2B86.9030205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	leedom@chelsio.com
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11738 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755188Ab1EKQfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 12:35:19 -0400
In-Reply-To: <4DCA2B86.9030205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2011 11:24 PM, Shan Wei wrote:
> As Dimitris Michailidis suggested, use NETIF_F_ALL_TSO for vlan_features,
> which is a mask, but not hw_features.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

While these changes aren't wrong I don't see a good reason to make them.  I am 
also curious why you're changing only these three drivers.

> ---
>  drivers/net/bnx2x/bnx2x_main.c     |    2 +-
>  drivers/net/cxgb4/cxgb4_main.c     |    2 +-
>  drivers/net/cxgb4vf/cxgb4vf_main.c |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index 2762edf..172684b 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -9267,7 +9267,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
>  		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
>  
>  	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> -		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
> +		NETIF_F_ALL_TSO | NETIF_F_HIGHDMA;
>  
>  	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
>  	if (bp->flags & USING_DAC_FLAG)
> diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
> index 7e3cfbe..21a163c 100644
> --- a/drivers/net/cxgb4/cxgb4_main.c
> +++ b/drivers/net/cxgb4/cxgb4_main.c
> @@ -3528,7 +3528,7 @@ static void free_some_resources(struct adapter *adapter)
>  }
>  
>  #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
> -#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
> +#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_ALL_TSO | \
>  		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
>  
>  static int __devinit init_one(struct pci_dev *pdev,
> diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
> index e71c08e..b55c521 100644
> --- a/drivers/net/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
> @@ -2604,7 +2604,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
>  		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
>  			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
> -		netdev->vlan_features = NETIF_F_SG | TSO_FLAGS |
> +		netdev->vlan_features = NETIF_F_SG | NETIF_F_ALL_TSO |
>  			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			NETIF_F_HIGHDMA;
>  		netdev->features = netdev->hw_features |

