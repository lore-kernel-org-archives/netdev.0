From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 1/2 net-next] ixgbe: use skb_padto
Date: Mon, 18 Jun 2012 14:18:47 -0700
Message-ID: <4FDF9B37.3030804@intel.com>
References: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39667 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443Ab2FRVSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 17:18:48 -0400
In-Reply-To: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2012 10:58 AM, Stephen Hemminger wrote:
> The code to pad packets here is the same effective code as
> the existing inline function skb_padto(). There is a minor
> performance gain since skb_padto() also uses unlikely().
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:53:09.130376800 -0700
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:55:13.104540844 -0700
> @@ -6389,11 +6389,8 @@ static netdev_tx_t ixgbe_xmit_frame(stru
>  	 * The minimum packet size for olinfo paylen is 17 so pad the skb
>  	 * in order to meet this minimum size requirement.
>  	 */
> -	if (skb->len < 17) {
> -		if (skb_padto(skb, 17))
> -			return NETDEV_TX_OK;
> -		skb->len = 17;
> -	}
> +	if (skb_padto(skb, 17))
> +		return NETDEV_TX_OK;
>  
>  	tx_ring = adapter->tx_ring[skb->queue_mapping];
>  	return ixgbe_xmit_frame_ring(skb, adapter, tx_ring);
I don't think this will work.  We need to update the skb->len and last I
knew skb_padto doesn't do that.

Thanks,

Alex
