From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Wed, 07 Dec 2011 14:36:20 +0800
Message-ID: <4EDF0964.3080509@linux.vnet.ibm.com>
References: <4EDED071.40900@linux.vnet.ibm.com> <1323229439.2415.23.camel@jtkirshe-mobl> <1323231268.1762.19.camel@joe2Laptop> <4EDEF05F.4020901@linux.vnet.ibm.com> <1323237700.1762.24.camel@joe2Laptop> <4EDF02CC.4010407@linux.vnet.ibm.com> <1323238749.1762.27.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:40239 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab1LGGgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 01:36:39 -0500
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 7 Dec 2011 12:06:31 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB76aPvs4239494
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 12:06:25 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB76aOXM015643
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 17:36:24 +1100
In-Reply-To: <1323238749.1762.27.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2011 02:19 PM, Joe Perches wrote:

> On Wed, 2011-12-07 at 14:08 +0800, Michael Wang wrote:
>> I'm not good at script, if you are interested, we can work together to
>> fix all the remain cases, and send out some patches.
> 
> You should try coccinelle and spatch.
> 

Hi, Joe

I have not used coccinelle and spatch before, I will study on them later.

> If you run the script, this is the intel output.
> 
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   10 +++++-----
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |    4 ++--
>  4 files changed, 9 insertions(+), 9 deletions(-)


We can try to fix them, thanks for the suggestion.

Regards,
Michael Wang

> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 82f4ef1..5526881 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -1185,7 +1185,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>  		if (global_quad_port_a != 0)
>  			adapter->eeprom_wol = 0;
>  		else
> -			adapter->quad_port_a = 1;
> +			adapter->quad_port_a = true;
>  		/* Reset for multiple quad port adapters */
>  		if (++global_quad_port_a == 4)
>  			global_quad_port_a = 0;
> @@ -1679,7 +1679,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
>  	 * need this to apply a workaround later in the send path. */
>  	if (hw->mac_type == e1000_82544 &&
>  	    hw->bus_type == e1000_bus_type_pcix)
> -		adapter->pcix_82544 = 1;
> +		adapter->pcix_82544 = true;
> 
>  	ew32(TCTL, tctl);
> 
> @@ -2002,7 +2002,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
> 
>  	tx_ring->next_to_use = 0;
>  	tx_ring->next_to_clean = 0;
> -	tx_ring->last_tx_tso = 0;
> +	tx_ring->last_tx_tso = false;
> 
>  	writel(0, hw->hw_addr + tx_ring->tdh);
>  	writel(0, hw->hw_addr + tx_ring->tdt);
> @@ -2851,7 +2851,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
>  		 * DMA'd to the controller */
>  		if (!skb->data_len && tx_ring->last_tx_tso &&
>  		    !skb_is_gso(skb)) {
> -			tx_ring->last_tx_tso = 0;
> +			tx_ring->last_tx_tso = false;
>  			size -= 4;
>  		}
> 
> @@ -3219,7 +3219,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
> 
>  	if (likely(tso)) {
>  		if (likely(hw->mac_type != e1000_82544))
> -			tx_ring->last_tx_tso = 1;
> +			tx_ring->last_tx_tso = true;
>  		tx_flags |= E1000_TX_FLAGS_TSO;
>  	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
>  		tx_flags |= E1000_TX_FLAGS_CSUM;
> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> index 247cf92..7fc6073 100644
> --- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> +++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> @@ -228,7 +228,7 @@ ixgb_up(struct ixgb_adapter *adapter)
>  	if (IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_PCIX_MODE) {
>  		err = pci_enable_msi(adapter->pdev);
>  		if (!err) {
> -			adapter->have_msi = 1;
> +			adapter->have_msi = true;
>  			irq_flags = 0;
>  		}
>  		/* proceed to try to request regular interrupt */
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 1b28ed9..e8da825 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -4019,7 +4019,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
> 
>  		/* Mark all the VFs as inactive */
>  		for (i = 0 ; i < adapter->num_vfs; i++)
> -			adapter->vfinfo[i].clear_to_send = 0;
> +			adapter->vfinfo[i].clear_to_send = false;
> 
>  		/* ping all the active vfs to let them know we are going down */
>  		ixgbe_ping_all_vfs(adapter);
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> index 9a56fd7..2c2a341 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> @@ -1646,9 +1646,9 @@ static bool ixgbe_get_i2c_data(u32 *i2cctl)
>  	bool data;
> 
>  	if (*i2cctl & IXGBE_I2C_DATA_IN)
> -		data = 1;
> +		data = true;
>  	else
> -		data = 0;
> +		data = false;
> 
>  	return data;
>  }
> 
> 
