From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 01/12] ixgbe: Mailbox header and code module
Date: Thu, 10 Dec 2009 11:50:18 +1100
Message-ID: <20091210005018.GH4163@verge.net.au>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:32981 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbZLJAuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:50:13 -0500
Content-Disposition: inline
In-Reply-To: <20091208221258.28373.16663.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 02:13:12PM -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The 82599 virtual function device and the master 82599 physical function
> device implement a mailbox utility for communication between the devices
> using some SRAM scratch memory and a doorbell/answering mechanism enabled
> via interrupt and/or polling.  This C module and accompanying header
> file implement the base functions for use of this feature.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_mbx.c |  480 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_mbx.h |   96 ++++++++
>  2 files changed, 576 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ixgbe/ixgbe_mbx.c
>  create mode 100644 drivers/net/ixgbe/ixgbe_mbx.h
> 
> diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
> new file mode 100644
> index 0000000..5cd5ae8
> --- /dev/null
> +++ b/drivers/net/ixgbe/ixgbe_mbx.c

[snip]

> +/**
> + *  ixgbe_init_mbx_params_pf - set initial values for pf mailbox
> + *  @hw: pointer to the HW structure
> + *
> + *  Initializes the hw->mbx struct to correct values for pf mailbox
> + */
> +s32 ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
> +{
> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
> +
> +	if (hw->mac.type == ixgbe_mac_82599EB) {
> +		mbx->timeout = 0;
> +		mbx->usec_delay = 0;
> +
> +		mbx->size = IXGBE_VFMAILBOX_SIZE;
> +
> +		mbx->stats.msgs_tx = 0;
> +		mbx->stats.msgs_rx = 0;
> +		mbx->stats.reqs = 0;
> +		mbx->stats.acks = 0;
> +		mbx->stats.rsts = 0;
> +	}
> +
> +	return 0;
> +}

Does ixgbe_init_mbx_params_pf() need a return value?
The only caller seems to ignore it.

Also, I prefer the following idiom, but in this case
it doesn't seem to offer any advantage:

void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
{
	struct ixgbe_mbx_info *mbx = &hw->mbx;

	if (hw->mac.type != ixgbe_mac_82599EB)
		return;

	mbx->timeout = 0;
	mbx->usec_delay = 0;

	mbx->size = IXGBE_VFMAILBOX_SIZE;

	mbx->stats.msgs_tx = 0;
	mbx->stats.msgs_rx = 0;
	mbx->stats.reqs = 0;
	mbx->stats.acks = 0;
	mbx->stats.rsts = 0;
}
