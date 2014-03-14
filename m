From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/16] ixgbe: add check for netif_carrier_ok in
 ixgbe_xmit_frame
Date: Fri, 14 Mar 2014 14:57:35 -0400 (EDT)
Message-ID: <20140314.145735.289100032884651109.davem@davemloft.net>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1394790446-31591-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, asharma@fb.com,
	stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1394790446-31591-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Mar 2014 02:47:11 -0700

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 851c413..8bea6ca 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7121,6 +7121,11 @@ static netdev_tx_t __ixgbe_xmit_frame(struct sk_buff *skb,
>  	struct ixgbe_adapter *adapter = netdev_priv(netdev);
>  	struct ixgbe_ring *tx_ring;
>  
> +	if (!netif_carrier_ok(netdev)) {
> +		dev_kfree_skb_any(skb);
> +		return NETDEV_TX_OK;
> +	}
> +

I would much prefer that this check moves into netpoll's direct invocation of
->ndo_start_xmit().

Otherwise every driver will start to add this check and that kind of
duplication doesn't make any sense at all.
