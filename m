From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 2/2] bnx2x: Fix kernel crash and data miscompare
 after EEH recovery
Date: Sun, 01 Jun 2014 19:26:13 -0700 (PDT)
Message-ID: <20140601.192613.1152234930286860733.davem@davemloft.net>
References: <20140528155641.920171803@linux.vnet.ibm.com>
	<20140528155722.361752083@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org, miltonm@bga.com
To: wenxiong@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbaFBC0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 22:26:14 -0400
In-Reply-To: <20140528155722.361752083@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wenxiong@linux.vnet.ibm.com
Date: Wed, 28 May 2014 10:56:43 -0500

> A rmb() is required to ensure that the CQE is not read before it
> is written by the adapter DMA.  PCI ordering rules will make sure
> the other fields are written before the marker at the end of struct
> eth_fast_path_rx_cqe but without rmb() a weakly ordered processor can
> process stale data.
> 
> Without the barrier we have observed various crashes including
> bnx2x_tpa_start being called on queues not stopped (resulting in message
> start of bin not in stop) and NULL pointer exceptions from bnx2x_rx_int.
> 
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Wen Xiong <wenxiong@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> Index: b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> ===================================================================
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c	2014-05-23 10:34:21.000000000 -0500
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c	2014-05-28 10:54:26.627766086 -0500
> @@ -906,6 +906,18 @@ static int bnx2x_rx_int(struct bnx2x_fas
>  		bd_prod = RX_BD(bd_prod);
>  		bd_cons = RX_BD(bd_cons);
>  
> +		/* A rmb() is required to ensure that the CQE is not read
> +		 * before it is written by the adapter DMA.  PCI ordering
> +		 * rules will make sure the other fields are written before
> +		 * the marker at the end of struct eth_fast_path_rx_cqe
> +		 * but without rmb() a weakly ordered processor can process
> +		 * stale data.  Without the barrier TPA state-machine might
> +		 * enter inconsistent state and kernel stack might be
> +		 * provided with incorrect packet description - these lead
> +		 * to various kernel crashed.
> +		*/

Missing a space before the final "*/", this is not formatted correctly.

Please fix this and resubmit the whole series.
