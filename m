From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: fix crash due to manipulating queues before registration
Date: Wed, 27 Oct 2010 23:35:29 -0700
Message-ID: <4CC919B1.1040602@chelsio.com>
References: <1288236563.2658.59.camel@edumazet-laptop> <1288242390-28574-1-git-send-email-nacc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sonnyrao@us.ibm.com,
	Dimitrios Michailidis <dm@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nishanth Aravamudan <nacc@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23817 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab0J1Gs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 02:48:57 -0400
In-Reply-To: <1288242390-28574-1-git-send-email-nacc@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2010 10:06 PM, Nishanth Aravamudan wrote:
> Hi Eric,
>
> Something like the following?:
>
> Thanks,
> Nish
>
>
> Along the same lines as "cxgb4: fix crash due to manipulating queues
> before registration" (8f6d9f40476895571df039b6f1f5230ec7faebad), before
> commit "net: allocate tx queues in register_netdevice"
> netif_tx_stop_all_queues and related functions could be used between
> device allocation and registration but now only after registration.
> cxgb4 has such a call before registration and crashes now.  Move it
> after register_netdev.
>
> Signed-off-by: Nishanth Aravamudan<nacc@us.ibm.com>

Acked-by: Divy Le Ray <divy@chelsio.com>

> Cc: eric.dumazet@gmail.com
> Cc: sonnyrao@us.ibm.com
> Cc: Divy Le Ray<divy@chelsio.com>
> Cc: Dimitris Michailidis<dm@chelsio.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>   drivers/net/cxgb3/cxgb3_main.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 4e3c123..96c70a5 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -3301,7 +3301,6 @@ static int __devinit init_one(struct pci_dev *pdev,
>   		pi->rx_offload = T3_RX_CSUM | T3_LRO;
>   		pi->port_id = i;
>   		netif_carrier_off(netdev);
> -		netif_tx_stop_all_queues(netdev);
>   		netdev->irq = pdev->irq;
>   		netdev->mem_start = mmio_start;
>   		netdev->mem_end = mmio_start + mmio_len - 1;
> @@ -3342,6 +3341,7 @@ static int __devinit init_one(struct pci_dev *pdev,
>   				adapter->name = adapter->port[i]->name;
>
>   			__set_bit(i,&adapter->registered_device_map);
> +			 netif_tx_stop_all_queues(adapter->port[i]);
>   		}
>   	}
>   	if (!adapter->registered_device_map) {


