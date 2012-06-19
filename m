From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC net-next 07/14] Fix intel/ixgbe
Date: Tue, 19 Jun 2012 08:54:53 -0700
Message-ID: <4FE0A0CD.5050909@intel.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com> <1340118848-30978-8-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29900 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754803Ab2FSPyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:54 -0400
In-Reply-To: <1340118848-30978-8-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2012 08:14 AM, Yuval Mintz wrote:
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> index af1a531..21e4513 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> @@ -802,7 +802,8 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
>  	 * The default is to use pairs of vectors.
>  	 */
>  	v_budget = max(adapter->num_rx_queues, adapter->num_tx_queues);
> -	v_budget = min_t(int, v_budget, num_online_cpus());
> +	v_budget = min_t(int, v_budget, min_t(int, num_online_cpus(),
> +					      DEFAULT_MAX_NUM_RSS_QUEUES));
>  	v_budget += NON_Q_VECTORS;
>  
>  	/*
This patch doesn't limit the number of queues.  It is limiting the
number of interrupts.  The two are not directly related as we can
support multiple queues per interrupt.

Also this change assumes we are only using receive side scaling.  We
have other features such as DCB, FCoE, and Flow Director which require
additional queues.

Thanks,

Alex
