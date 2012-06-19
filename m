From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC net-next 06/14] Fix intel/igb
Date: Tue, 19 Jun 2012 08:42:55 -0700
Message-ID: <4FE09DFF.704@intel.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com> <1340118848-30978-7-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12862 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457Ab2FSPnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:43:03 -0400
In-Reply-To: <1340118848-30978-7-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2012 08:14 AM, Yuval Mintz wrote:
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index dd3bfe8..8e7ade5 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2380,18 +2380,20 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
>  #endif /* CONFIG_PCI_IOV */
>  	switch (hw->mac.type) {
>  	case e1000_i210:
> -		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES_I210,
> -			num_online_cpus());
> +		adapter->rss_queues = IGB_MAX_RX_QUEUES_I210;
>  		break;
>  	case e1000_i211:
> -		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES_I211,
> -			num_online_cpus());
> +		adapter->rss_queues = IGB_MAX_RX_QUEUES_I211;
>  		break;
>  	default:
> -		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES,
> -		num_online_cpus());
> +		adapter->rss_queues = IGB_MAX_RX_QUEUES;
>  		break;
>  	}
> +
> +	adapter->rss_queues = min_t(u32, adapter->rss_queues,
> +				    min_t(u32, num_online_cpus(),
> +					  DEFAULT_MAX_NUM_RSS_QUEUES));
> +
>  	/* i350 cannot do RSS and SR-IOV at the same time */
>  	if (hw->mac.type == e1000_i350 && adapter->vfs_allocated_count)
>  		adapter->rss_queues = 1;
Same issue here as ixgbevf, only we support a max of 8 Rx queues in the
hardware.  So now you are once again adding another unnecessary limit on
something that is already limited to 8 or less.

Thanks,

Alex
