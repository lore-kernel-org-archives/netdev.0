From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] cxgb3: Set vlan_feature on net_device
Date: Wed, 18 Jul 2012 13:12:41 -0700
Message-ID: <500718B9.8000508@hp.com>
References: <1342639748-16276-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "divy@chelsio.com" <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "brenohl@br.ibm.com" <brenohl@br.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:27124 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab2GRUMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:12:44 -0400
In-Reply-To: <1342639748-16276-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2012 12:29 PM, brenohl@br.ibm.com wrote:
> cxgb3 interface has a bad performance when VLAN is set. On my current
> setup, a PowerLinux 7R2, I am able to get around 7 Gbps on a TCP_STREAM
> (8 instances, 4k message).
> With this patch, I am able to reach 9.5 Gbps.
Getting service demand out of an aggregate netperf test is a chore, but 
reporting the change in CPU utilization should be pretty 
straightforward.   Since you ended-up being constrained by link-rate, 
showing the CPU utilization change (and calculating service demand 
manually if you feel up to it) may help show the change has an even 
greater effect then (9.5-7)/7 or 35%.

What does the change do for latency and/or maximum,  min-sized packets 
per second.

rick jones
there is more to the network than just bits/s :)

>
> Signed-off-by: Breno Leitao <brenohl@br.ibm.com>
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
> index abb6ce7..fcf4b31 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
> @@ -3173,6 +3173,9 @@ static void __devinit cxgb3_init_iscsi_mac(struct net_device *dev)
>   	pi->iscsic.mac_addr[3] |= 0x80;
>   }
>   
> +#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
> +#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
> +			NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
>   static int __devinit init_one(struct pci_dev *pdev,
>   			      const struct pci_device_id *ent)
>   {
> @@ -3293,6 +3296,7 @@ static int __devinit init_one(struct pci_dev *pdev,
>   		netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
>   			NETIF_F_TSO | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX;
>   		netdev->features |= netdev->hw_features | NETIF_F_HW_VLAN_TX;
> +		netdev->vlan_features |= netdev->features & VLAN_FEAT;
>   		if (pci_using_dac)
>   			netdev->features |= NETIF_F_HIGHDMA;
>   
