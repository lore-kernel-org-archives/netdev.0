From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 6/9] ixgbe: add support for X550
 source_address_prunning
Date: Fri, 10 Apr 2015 02:02:46 -0700
Message-ID: <1428656566.5413.23.camel@perches.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1428652398-10147-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0182.hostedemail.com ([216.40.44.182]:40606 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755392AbbDJJCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 05:02:51 -0400
In-Reply-To: <1428652398-10147-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 00:53 -0700, Jeff Kirsher wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>

Trivia:

> This patch will enable X550 Source Address Prunning for VEPA

Pruning

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
[]
> @@ -7880,13 +7880,57 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  static int ixgbe_configure_bridge_mode(struct ixgbe_adapter *adapter,
>  				       __u16 mode)
>  {
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	unsigned int p, num_pools;
> +	u32 vmdctl;

Maybe add a temporary for

	struct ixgbe_mac_operations *ops = &hw->mac.ops;

[]

>  	switch (mode) {
>  	case BRIDGE_MODE_VEPA:
[]
> +		for (p = 0; p < num_pools; p++) {
> +			if (hw->mac.ops.set_source_address_pruning)
> +				hw->mac.ops.set_source_address_pruning(hw,
> +								       true,
> +								       p);

so this can be:
				ops->set_source_address_pruning(hw, true, p);

>  	case BRIDGE_MODE_VEB:
[]
> +		for (p = 0; p < num_pools; p++) {
> +			if (hw->mac.ops.set_source_address_pruning)
> +				hw->mac.ops.set_source_address_pruning(hw,
> +								       false,
> +								       p);

here too
