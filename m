From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next-2.6] ixgbe: Use the instance of
 net_device_stats	from net_device.
Date: Thu, 8 Oct 2009 15:55:11 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F98A89A0B@rrsmsx501.amr.corp.intel.com>
References: <20091007124339.GA30083@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Ajit Khaparde <ajitk@serverengines.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31802 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755508AbZJHVzu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 17:55:50 -0400
In-Reply-To: <20091007124339.GA30083@serverengines.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajit Khaparde wrote:
> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the private adapter structure.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> ---
>  drivers/net/ixgbe/ixgbe.h         |    1 -
>  drivers/net/ixgbe/ixgbe_ethtool.c |   40
>  +++++++++++++++++++----------------- drivers/net/ixgbe/ixgbe_main.c 
>  |   26 ++++++++++++------------ 3 files changed, 34 insertions(+),
> 33 deletions(-) 
> 
> diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> index 28f32da..2b85416 100644
> --- a/drivers/net/ixgbe/ixgbe.h
> +++ b/drivers/net/ixgbe/ixgbe.h
> @@ -340,7 +340,6 @@ struct ixgbe_adapter {
>  	/* OS defined structs */
>  	struct net_device *netdev;
>  	struct pci_dev *pdev;
> -	struct net_device_stats net_stats;
> 
>  	u32 test_icr;
>  	struct ixgbe_ring test_tx_ring;
> diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c
> b/drivers/net/ixgbe/ixgbe_ethtool.c index fa314cb..987b41c 100644
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> @@ -48,11 +48,13 @@ struct ixgbe_stats {
> 
>  #define IXGBE_STAT(m) sizeof(((struct ixgbe_adapter *)0)->m), \
>                               offsetof(struct ixgbe_adapter, m)
> +#define IXGBE_NETDEV_STAT(m) sizeof(((struct net_device *)0)->m), \
> +                             offsetof(struct net_device, m)
>  static struct ixgbe_stats ixgbe_gstrings_stats[] = {
> -	{"rx_packets", IXGBE_STAT(net_stats.rx_packets)},
> -	{"tx_packets", IXGBE_STAT(net_stats.tx_packets)},
> -	{"rx_bytes", IXGBE_STAT(net_stats.rx_bytes)},
> -	{"tx_bytes", IXGBE_STAT(net_stats.tx_bytes)},
> +	{"rx_packets", IXGBE_NETDEV_STAT(stats.rx_packets)},
> +	{"tx_packets", IXGBE_NETDEV_STAT(stats.tx_packets)},
> +	{"rx_bytes", IXGBE_NETDEV_STAT(stats.rx_bytes)},
> +	{"tx_bytes", IXGBE_NETDEV_STAT(stats.tx_bytes)},
>  	{"rx_pkts_nic", IXGBE_STAT(stats.gprc)},
>  	{"tx_pkts_nic", IXGBE_STAT(stats.gptc)},
>  	{"rx_bytes_nic", IXGBE_STAT(stats.gorc)},
> @@ -60,26 +62,26 @@ static struct ixgbe_stats ixgbe_gstrings_stats[]
>  	= { {"lsc_int", IXGBE_STAT(lsc_int)},
>  	{"tx_busy", IXGBE_STAT(tx_busy)},
>  	{"non_eop_descs", IXGBE_STAT(non_eop_descs)},
> -	{"rx_errors", IXGBE_STAT(net_stats.rx_errors)},
> -	{"tx_errors", IXGBE_STAT(net_stats.tx_errors)},
> -	{"rx_dropped", IXGBE_STAT(net_stats.rx_dropped)},
> -	{"tx_dropped", IXGBE_STAT(net_stats.tx_dropped)},
> -	{"multicast", IXGBE_STAT(net_stats.multicast)},
> +	{"rx_errors", IXGBE_NETDEV_STAT(stats.rx_errors)},
> +	{"tx_errors", IXGBE_NETDEV_STAT(stats.tx_errors)},
> +	{"rx_dropped", IXGBE_NETDEV_STAT(stats.rx_dropped)},
> +	{"tx_dropped", IXGBE_NETDEV_STAT(stats.tx_dropped)},
> +	{"multicast", IXGBE_NETDEV_STAT(stats.multicast)},
>  	{"broadcast", IXGBE_STAT(stats.bprc)},
>  	{"rx_no_buffer_count", IXGBE_STAT(stats.rnbc[0]) },
> -	{"collisions", IXGBE_STAT(net_stats.collisions)},
> -	{"rx_over_errors", IXGBE_STAT(net_stats.rx_over_errors)},
> -	{"rx_crc_errors", IXGBE_STAT(net_stats.rx_crc_errors)},
> -	{"rx_frame_errors", IXGBE_STAT(net_stats.rx_frame_errors)},
> +	{"collisions", IXGBE_NETDEV_STAT(stats.collisions)},
> +	{"rx_over_errors", IXGBE_NETDEV_STAT(stats.rx_over_errors)},
> +	{"rx_crc_errors", IXGBE_NETDEV_STAT(stats.rx_crc_errors)},
> +	{"rx_frame_errors", IXGBE_NETDEV_STAT(stats.rx_frame_errors)},
>  	{"hw_rsc_count", IXGBE_STAT(rsc_count)},
>  	{"fdir_match", IXGBE_STAT(stats.fdirmatch)},
>  	{"fdir_miss", IXGBE_STAT(stats.fdirmiss)},
> -	{"rx_fifo_errors", IXGBE_STAT(net_stats.rx_fifo_errors)},
> -	{"rx_missed_errors", IXGBE_STAT(net_stats.rx_missed_errors)},
> -	{"tx_aborted_errors", IXGBE_STAT(net_stats.tx_aborted_errors)},
> -	{"tx_carrier_errors", IXGBE_STAT(net_stats.tx_carrier_errors)},
> -	{"tx_fifo_errors", IXGBE_STAT(net_stats.tx_fifo_errors)},
> -	{"tx_heartbeat_errors", IXGBE_STAT(net_stats.tx_heartbeat_errors)},
> +	{"rx_fifo_errors", IXGBE_NETDEV_STAT(stats.rx_fifo_errors)},
> +	{"rx_missed_errors", IXGBE_NETDEV_STAT(stats.rx_missed_errors)},
> +	{"tx_aborted_errors", IXGBE_NETDEV_STAT(stats.tx_aborted_errors)},
> +	{"tx_carrier_errors", IXGBE_NETDEV_STAT(stats.tx_carrier_errors)},
> +	{"tx_fifo_errors", IXGBE_NETDEV_STAT(stats.tx_fifo_errors)},
> +	{"tx_heartbeat_errors",
>  	IXGBE_NETDEV_STAT(stats.tx_heartbeat_errors)}, {"tx_timeout_count",
>  	IXGBE_STAT(tx_timeout_count)}, {"tx_restart_queue",
>  	IXGBE_STAT(restart_queue)}, {"rx_long_length_errors",
> IXGBE_STAT(stats.roc)}, 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c
> b/drivers/net/ixgbe/ixgbe_main.c 
> index cbb143c..c91d50e 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -372,8 +372,8 @@ static bool ixgbe_clean_tx_irq(struct
>  	ixgbe_q_vector *q_vector, tx_ring->total_packets += total_packets;
>  	tx_ring->stats.packets += total_packets;
>  	tx_ring->stats.bytes += total_bytes;
> -	adapter->net_stats.tx_bytes += total_bytes;
> -	adapter->net_stats.tx_packets += total_packets;
> +	netdev->stats.tx_bytes += total_bytes;
> +	netdev->stats.tx_packets += total_packets;
>  	return (count < tx_ring->work_limit);
>  }
> 
> @@ -709,6 +709,7 @@ static bool ixgbe_clean_rx_irq(struct
>                                 ixgbe_q_vector *q_vector, int
>  *work_done, int work_to_do) {
>  	struct ixgbe_adapter *adapter = q_vector->adapter;
> +	struct net_device *netdev = adapter->netdev;
>  	struct pci_dev *pdev = adapter->pdev;
>  	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
>  	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
> @@ -880,8 +881,8 @@ next_desc:
> 
>  	rx_ring->total_packets += total_rx_packets;
>  	rx_ring->total_bytes += total_rx_bytes;
> -	adapter->net_stats.rx_bytes += total_rx_bytes;
> -	adapter->net_stats.rx_packets += total_rx_packets;
> +	netdev->stats.rx_bytes += total_rx_bytes;
> +	netdev->stats.rx_packets += total_rx_packets;
> 
>  	return cleaned;
>  }
> @@ -4403,6 +4404,7 @@ static void ixgbe_shutdown(struct pci_dev *pdev)
>   **/
>  void ixgbe_update_stats(struct ixgbe_adapter *adapter)
>  {
> +	struct net_device *netdev = adapter->netdev;
>  	struct ixgbe_hw *hw = &adapter->hw;
>  	u64 total_mpc = 0;
>  	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
> @@ -4522,15 +4524,15 @@ void ixgbe_update_stats(struct ixgbe_adapter
>  	*adapter) adapter->stats.bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
> 
>  	/* Fill out the OS statistics structure */
> -	adapter->net_stats.multicast = adapter->stats.mprc;
> +	netdev->stats.multicast = adapter->stats.mprc;
> 
>  	/* Rx Errors */
> -	adapter->net_stats.rx_errors = adapter->stats.crcerrs +
> +	netdev->stats.rx_errors = adapter->stats.crcerrs +
>  	                               adapter->stats.rlec;
> -	adapter->net_stats.rx_dropped = 0;
> -	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
> -	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
> -	adapter->net_stats.rx_missed_errors = total_mpc;
> +	netdev->stats.rx_dropped = 0;
> +	netdev->stats.rx_length_errors = adapter->stats.rlec;
> +	netdev->stats.rx_crc_errors = adapter->stats.crcerrs;
> +	netdev->stats.rx_missed_errors = total_mpc;
>  }
> 
>  /**
> @@ -5300,10 +5302,8 @@ static netdev_tx_t ixgbe_xmit_frame(struct
>   sk_buff *skb, **/
>  static struct net_device_stats *ixgbe_get_stats(struct net_device
>  *netdev) {
> -	struct ixgbe_adapter *adapter = netdev_priv(netdev);
> -
>  	/* only return the current stats */
> -	return &adapter->net_stats;
> +	return &netdev->stats;
>  }
> 
>  /**
> --
> 1.6.0.4

I am seeing an issues with these patches where some counters are messed up:

--- ixgbe ---

NIC statistics:
     rx_packets: 18446612147046614784
     tx_packets: 18446612147046614784
     rx_bytes: 18446744072099799523
     tx_bytes: 18446744072099857640
     rx_pkts_nic: 12
     tx_pkts_nic: 19
     rx_bytes_nic: 1148
     tx_bytes_nic: 1762
     lsc_int: 4
     tx_busy: 0
     non_eop_descs: 0
     rx_errors: 0
     tx_errors: 18446744072099850983
     rx_dropped: 18446612140591825160
     tx_dropped: 18446612140591825424
     multicast: 18446612140591825952
     broadcast: 0
     rx_no_buffer_count: 0
     collisions: 18446612140591825688
     rx_over_errors: 18446612140591827008
     rx_crc_errors: 18446612140591827272
     rx_frame_errors: 18446612140591827536
     hw_rsc_count: 0
     fdir_match: 0
     fdir_miss: 10
     rx_fifo_errors: 18446612140591827800
     rx_missed_errors: 18446612140591828064
     tx_aborted_errors: 18446612140591828328
     tx_carrier_errors: 18446612140591828592
     tx_fifo_errors: 18446612140591828856
     tx_heartbeat_errors: 18446612140591829120
	...

--- igb ---
NIC statistics:
     rx_packets: 0
     tx_packets: 0
     rx_bytes: 0
     tx_bytes: 0
     rx_broadcast: 0
     tx_broadcast: 0
     rx_multicast: 0
     tx_multicast: 0
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 18446744072099036908
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 65535
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_no_buffer_count: 0
     rx_queue_drop_packet_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 18446612146842011544
	...

--- e1000 ---
NIC statistics:
     rx_packets: 0
     tx_packets: 0
     rx_bytes: 0
     tx_bytes: 0
     rx_broadcast: 0
     tx_broadcast: 0
     rx_multicast: 0
     tx_multicast: 0
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 18446744072099165544
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 18446744072099094496
     rx_no_buffer_count: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 4294967295
	...

 --- e1000e ---
NIC statistics:
     rx_packets: 0
     tx_packets: 7
     rx_bytes: 0
     tx_bytes: 614
     rx_broadcast: 0
     tx_broadcast: 0
     rx_multicast: 0
     tx_multicast: 7
     rx_errors: 0
     tx_errors: 0
     tx_dropped: 18446744072099315636

Thanks,
Emil