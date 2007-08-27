From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH net-2.6.24] e100: fix driver init lockup
 on	e100_up()
Date: Mon, 27 Aug 2007 10:09:51 -0700
Message-ID: <46D3055F.5060201@intel.com>
References: <200708271706.l7RH6wT0024567@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2427 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757760AbXH0RK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 13:10:26 -0400
In-Reply-To: <200708271706.l7RH6wT0024567@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> Recent NAPI changes require that napi_enable() is always matched with
> a napi_disable(). This patch makes sure that this invariant holds for
> e100. It also moves the netif_napi_add() call until after private
> pointers have been intialized, though this might only be significant
> for cases where netpoll is being used.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index e25f5ec..48996a4 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -2575,11 +2575,12 @@ static int __devinit e100_probe(struct pci_dev *pdev,
>  	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
>  
>  	nic = netdev_priv(netdev);
> -	netif_napi_add(netdev, &nic->napi, e100_poll, E100_NAPI_WEIGHT);
>  	nic->netdev = netdev;
>  	nic->pdev = pdev;
>  	nic->msg_enable = (1 << debug) - 1;
>  	pci_set_drvdata(pdev, netdev);
> +	netif_napi_add(netdev, &nic->napi, e100_poll, E100_NAPI_WEIGHT);
> +	napi_disable(&nic->napi);

Just wondering, could we even reverse this order? IOW disable NAPI first, then 
add it ?

Otherwise this sounds OK to me.

Auke
