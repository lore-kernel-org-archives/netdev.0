From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] Naming interrupt vectors/ixgbe
Date: Tue, 25 Nov 2008 10:20:24 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0811251019190.6404@ppwaskie-MOBL2.amr.corp.intel.com>
References: <18732.7795.484291.202338@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Robert.Olsson@data.slu.se" <Robert.Olsson@data.slu.se>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43506 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbYKYSUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:20:32 -0500
In-Reply-To: <18732.7795.484291.202338@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Nov 2008, Robert Olsson wrote:

> 
> Same syntax for ixgbe driver.
> 
> Cheers
> 				--ro
> 
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
> 
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 7548fb7..88717e6 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -1187,6 +1187,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
>  	struct net_device *netdev = adapter->netdev;
>  	irqreturn_t (*handler)(int, void *);
>  	int i, vector, q_vectors, err;
> +	int ri=0, ti=0;

Tiny nit, ri = 0, ti = 0;

I can live with it though.

>  
>  	/* Decrement for Other and TCP Timer vectors */
>  	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
> @@ -1201,10 +1202,19 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
>                           &ixgbe_msix_clean_many)
>  	for (vector = 0; vector < q_vectors; vector++) {
>  		handler = SET_HANDLER(&adapter->q_vector[vector]);
> -		sprintf(adapter->name[vector], "%s:v%d-%s",
> -		        netdev->name, vector,
> -		        (handler == &ixgbe_msix_clean_rx) ? "Rx" :
> -		         ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
> +
> +		if(handler == &ixgbe_msix_clean_rx) {
> +			sprintf(adapter->name[vector], "%s-%s-%d",
> +				netdev->name, "rx", ri++);
> +		}
> +		else if(handler == &ixgbe_msix_clean_tx) {
> +			sprintf(adapter->name[vector], "%s-%s-%d",
> +				netdev->name, "tx", ti++);
> +		}
> +		else 
> +			sprintf(adapter->name[vector], "%s-%s-%d",
> +				netdev->name, "TxRx", vector);	
> +
>  		err = request_irq(adapter->msix_entries[vector].vector,
>  		                  handler, 0, adapter->name[vector],
>  		                  &(adapter->q_vector[vector]));

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
