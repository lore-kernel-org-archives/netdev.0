From: roprabhu <roprabhu@cisco.com>
Subject: Re: [PATCH 6/9] enic: update to support 64 bit stats
Date: Thu, 09 Jun 2011 10:43:44 -0700
Message-ID: <CA165460.28E7E%roprabhu@cisco.com>
References: <20110609005417.630728228@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	David Wang <dwang2@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:34624 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207Ab1FIRnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 13:43:47 -0400
In-Reply-To: <20110609005417.630728228@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/11 5:54 PM, "Stephen Hemminger" <shemminger@vyatta.com> wrote:

> The device driver already uses 64 bit statistics, it just
> doesn't use the 64 bit interface.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/enic/enic_main.c 2011-06-07 16:58:31.317079332 -0700
> +++ b/drivers/net/enic/enic_main.c 2011-06-07 17:29:09.670195233 -0700
> @@ -801,10 +801,10 @@ static netdev_tx_t enic_hard_start_xmit(
>  }
>  
>  /* dev_base_lock rwlock held, nominally process context */
> -static struct net_device_stats *enic_get_stats(struct net_device *netdev)
> +static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
> +      struct rtnl_link_stats64 *net_stats)
>  {
> struct enic *enic = netdev_priv(netdev);
> - struct net_device_stats *net_stats = &netdev->stats;
> struct vnic_stats *stats;
>  
> enic_dev_stats_dump(enic, &stats);
> @@ -2117,7 +2117,7 @@ static const struct net_device_ops enic_
> .ndo_open  = enic_open,
> .ndo_stop  = enic_stop,
> .ndo_start_xmit  = enic_hard_start_xmit,
> - .ndo_get_stats  = enic_get_stats,
> + .ndo_get_stats64 = enic_get_stats,
> .ndo_validate_addr = eth_validate_addr,
> .ndo_set_rx_mode = enic_set_rx_mode,
> .ndo_set_multicast_list = enic_set_rx_mode,
> @@ -2139,7 +2139,7 @@ static const struct net_device_ops enic_
> .ndo_open  = enic_open,
> .ndo_stop  = enic_stop,
> .ndo_start_xmit  = enic_hard_start_xmit,
> - .ndo_get_stats  = enic_get_stats,
> + .ndo_get_stats64 = enic_get_stats,
> .ndo_validate_addr = eth_validate_addr,
> .ndo_set_mac_address = enic_set_mac_address,
> .ndo_set_rx_mode = enic_set_rx_mode,
> 

ACK..
Thanks Stephen. 

