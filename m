From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC net-next (v2) 14/14] ixgbevf: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 08:45:24 -0700
Message-ID: <4FE88794.9090704@intel.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com> <1340624745-8650-15-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42929 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756934Ab2FYPpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 11:45:25 -0400
In-Reply-To: <1340624745-8650-15-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2012 04:45 AM, Yuval Mintz wrote:
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index f69ec42..7889644 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -2023,7 +2023,7 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
>  	 * (roughly) twice the number of vectors as there are CPU's.
>  	 */
>  	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
> -		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
> +		       netif_get_num_default_rss_queues() * 2) + NON_Q_VECTORS;
>  
>  	/* A failure in MSI-X entry allocation isn't fatal, but it does
>  	 * mean we disable MSI-X capabilities of the adapter. */
I'm not even sure why you are bothering to alter this driver since it is
currently single queue only.

Thanks,

Alex
