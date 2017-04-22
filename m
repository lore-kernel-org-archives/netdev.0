From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] mlx5: fix space waste from ethtool descriptions
Date: Sat, 22 Apr 2017 03:49:50 +0300
Message-ID: <CALzJLG9f-bCaLnWyhBot8FyPomghsTfXhZJZqQ2g6NspkfMoew@mail.gmail.com>
References: <20170421181558.5414-1-sthemmin@microsoft.com> <20170421181558.5414-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Stephen Hemminger <sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170421181558.5414-4-sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 9:15 PM, Stephen Hemminger
<stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org> wrote:
> The ethtool statistics descriptions were declared as static in
> en_stats.h but that file is included indirectly in multiple places
> causing multiple unused redundant copies. This is reported by building
> with W=1.
>
> The solution is to move the description out of en_stats.h into
> the one file that uses them en_ethtool.c

Hi Stephen,

Thanks for the patches,

I really like patches #1 and #2, But i would like to keep this patch
out of this series for now.
I have some guys working now on adding and refactoring the stats
reporting mechanism in mlx5e and I also would like to keep the stats
descriptions outside of en_ethtool.c logic.

I totally agree with you and I will keep the wasted space issue in
mind and will ask the guys to fix it in their patches.

Deal ?

Thanks
Saeed.

>
> Signed-off-by: Stephen Hemminger <sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
> ---
>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 208 +++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 206 +-------------------
>  2 files changed, 209 insertions(+), 205 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> index ce7b09d72ff6..b1d9518b2719 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> @@ -31,6 +31,214 @@
>   */
>
>  #include "en.h"
> +#include "en_stats.h"
> +
> +
> +static const struct counter_desc sw_stats_desc[] = {
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_packets) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_bytes) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_packets) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_bytes) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_packets) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_bytes) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_inner_packets) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_inner_bytes) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_lro_packets) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_lro_bytes) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_unnecessary) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_none) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_complete) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_unnecessary_inner) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_drop) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_tx) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_tx_full) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial_inner) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_stopped) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_wake) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_dropped) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_xmit_more) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_wqe_err) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_filler) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_buff_alloc_err) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_blks) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_pkts) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_reuse) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_full) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_empty) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_busy) },
> +       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, link_down_events_phy) },
> +};
> +
> +static const struct counter_desc q_stats_desc[] = {
> +       { MLX5E_DECLARE_STAT(struct mlx5e_qcounter_stats, rx_out_of_buffer) },
> +};
> +
> +static const struct counter_desc vport_stats_desc[] = {
> +       { "rx_vport_unicast_packets",
> +               VPORT_COUNTER_OFF(received_eth_unicast.packets) },
> +       { "rx_vport_unicast_bytes",
> +               VPORT_COUNTER_OFF(received_eth_unicast.octets) },
> +       { "tx_vport_unicast_packets",
> +               VPORT_COUNTER_OFF(transmitted_eth_unicast.packets) },
> +       { "tx_vport_unicast_bytes",
> +               VPORT_COUNTER_OFF(transmitted_eth_unicast.octets) },
> +       { "rx_vport_multicast_packets",
> +               VPORT_COUNTER_OFF(received_eth_multicast.packets) },
> +       { "rx_vport_multicast_bytes",
> +               VPORT_COUNTER_OFF(received_eth_multicast.octets) },
> +       { "tx_vport_multicast_packets",
> +               VPORT_COUNTER_OFF(transmitted_eth_multicast.packets) },
> +       { "tx_vport_multicast_bytes",
> +               VPORT_COUNTER_OFF(transmitted_eth_multicast.octets) },
> +       { "rx_vport_broadcast_packets",
> +               VPORT_COUNTER_OFF(received_eth_broadcast.packets) },
> +       { "rx_vport_broadcast_bytes",
> +               VPORT_COUNTER_OFF(received_eth_broadcast.octets) },
> +       { "tx_vport_broadcast_packets",
> +               VPORT_COUNTER_OFF(transmitted_eth_broadcast.packets) },
> +       { "tx_vport_broadcast_bytes",
> +               VPORT_COUNTER_OFF(transmitted_eth_broadcast.octets) },
> +       { "rx_vport_rdma_unicast_packets",
> +               VPORT_COUNTER_OFF(received_ib_unicast.packets) },
> +       { "rx_vport_rdma_unicast_bytes",
> +               VPORT_COUNTER_OFF(received_ib_unicast.octets) },
> +       { "tx_vport_rdma_unicast_packets",
> +               VPORT_COUNTER_OFF(transmitted_ib_unicast.packets) },
> +       { "tx_vport_rdma_unicast_bytes",
> +               VPORT_COUNTER_OFF(transmitted_ib_unicast.octets) },
> +       { "rx_vport_rdma_multicast_packets",
> +               VPORT_COUNTER_OFF(received_ib_multicast.packets) },
> +       { "rx_vport_rdma_multicast_bytes",
> +               VPORT_COUNTER_OFF(received_ib_multicast.octets) },
> +       { "tx_vport_rdma_multicast_packets",
> +               VPORT_COUNTER_OFF(transmitted_ib_multicast.packets) },
> +       { "tx_vport_rdma_multicast_bytes",
> +               VPORT_COUNTER_OFF(transmitted_ib_multicast.octets) },
> +};
> +static const struct counter_desc pport_802_3_stats_desc[] = {
> +       { "tx_packets_phy", PPORT_802_3_OFF(a_frames_transmitted_ok) },
> +       { "rx_packets_phy", PPORT_802_3_OFF(a_frames_received_ok) },
> +       { "rx_crc_errors_phy", PPORT_802_3_OFF(a_frame_check_sequence_errors) },
> +       { "tx_bytes_phy", PPORT_802_3_OFF(a_octets_transmitted_ok) },
> +       { "rx_bytes_phy", PPORT_802_3_OFF(a_octets_received_ok) },
> +       { "tx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_xmitted_ok) },
> +       { "tx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_xmitted_ok) },
> +       { "rx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_received_ok) },
> +       { "rx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_received_ok) },
> +       { "rx_in_range_len_errors_phy", PPORT_802_3_OFF(a_in_range_length_errors) },
> +       { "rx_out_of_range_len_phy", PPORT_802_3_OFF(a_out_of_range_length_field) },
> +       { "rx_oversize_pkts_phy", PPORT_802_3_OFF(a_frame_too_long_errors) },
> +       { "rx_symbol_err_phy", PPORT_802_3_OFF(a_symbol_error_during_carrier) },
> +       { "tx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_transmitted) },
> +       { "rx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_received) },
> +       { "rx_unsupported_op_phy", PPORT_802_3_OFF(a_unsupported_opcodes_received) },
> +       { "rx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_received) },
> +       { "tx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_transmitted) },
> +};
> +
> +static const struct counter_desc pport_2863_stats_desc[] = {
> +       { "rx_discards_phy", PPORT_2863_OFF(if_in_discards) },
> +       { "tx_discards_phy", PPORT_2863_OFF(if_out_discards) },
> +       { "tx_errors_phy", PPORT_2863_OFF(if_out_errors) },
> +};
> +
> +static const struct counter_desc pport_2819_stats_desc[] = {
> +       { "rx_undersize_pkts_phy", PPORT_2819_OFF(ether_stats_undersize_pkts) },
> +       { "rx_fragments_phy", PPORT_2819_OFF(ether_stats_fragments) },
> +       { "rx_jabbers_phy", PPORT_2819_OFF(ether_stats_jabbers) },
> +       { "rx_64_bytes_phy", PPORT_2819_OFF(ether_stats_pkts64octets) },
> +       { "rx_65_to_127_bytes_phy", PPORT_2819_OFF(ether_stats_pkts65to127octets) },
> +       { "rx_128_to_255_bytes_phy", PPORT_2819_OFF(ether_stats_pkts128to255octets) },
> +       { "rx_256_to_511_bytes_phy", PPORT_2819_OFF(ether_stats_pkts256to511octets) },
> +       { "rx_512_to_1023_bytes_phy", PPORT_2819_OFF(ether_stats_pkts512to1023octets) },
> +       { "rx_1024_to_1518_bytes_phy", PPORT_2819_OFF(ether_stats_pkts1024to1518octets) },
> +       { "rx_1519_to_2047_bytes_phy", PPORT_2819_OFF(ether_stats_pkts1519to2047octets) },
> +       { "rx_2048_to_4095_bytes_phy", PPORT_2819_OFF(ether_stats_pkts2048to4095octets) },
> +       { "rx_4096_to_8191_bytes_phy", PPORT_2819_OFF(ether_stats_pkts4096to8191octets) },
> +       { "rx_8192_to_10239_bytes_phy", PPORT_2819_OFF(ether_stats_pkts8192to10239octets) },
> +};
> +
> +static const struct counter_desc pport_phy_statistical_stats_desc[] = {
> +       { "rx_symbol_errors_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
> +       { "rx_corrected_bits_phy", PPORT_PHY_STATISTICAL_OFF(phy_corrected_bits) },
> +};
> +
> +static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
> +       { "rx_prio%d_bytes", PPORT_PER_PRIO_OFF(rx_octets) },
> +       { "rx_prio%d_packets", PPORT_PER_PRIO_OFF(rx_frames) },
> +       { "tx_prio%d_bytes", PPORT_PER_PRIO_OFF(tx_octets) },
> +       { "tx_prio%d_packets", PPORT_PER_PRIO_OFF(tx_frames) },
> +};
> +
> +static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
> +       /* %s is "global" or "prio{i}" */
> +       { "rx_%s_pause", PPORT_PER_PRIO_OFF(rx_pause) },
> +       { "rx_%s_pause_duration", PPORT_PER_PRIO_OFF(rx_pause_duration) },
> +       { "tx_%s_pause", PPORT_PER_PRIO_OFF(tx_pause) },
> +       { "tx_%s_pause_duration", PPORT_PER_PRIO_OFF(tx_pause_duration) },
> +       { "rx_%s_pause_transition", PPORT_PER_PRIO_OFF(rx_pause_transition) },
> +};
> +
> +static const struct counter_desc pcie_perf_stats_desc[] = {
> +       { "rx_pci_signal_integrity", PCIE_PERF_OFF(rx_errors) },
> +       { "tx_pci_signal_integrity", PCIE_PERF_OFF(tx_errors) },
> +};
> +
> +static const struct counter_desc rq_stats_desc[] = {
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, packets) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, bytes) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_complete) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_unnecessary_inner) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_none) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_drop) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_tx) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_tx_full) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_packets) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_bytes) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, wqe_err) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, mpwqe_filler) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, buff_alloc_err) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_blks) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_pkts) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_reuse) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_full) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_empty) },
> +       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_busy) },
> +};
> +
> +static const struct counter_desc sq_stats_desc[] = {
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, packets) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, bytes) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_packets) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_bytes) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_inner_packets) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_inner_bytes) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, csum_partial_inner) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, nop) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, csum_none) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, stopped) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, wake) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, dropped) },
> +       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
> +};
> +
> +static const struct counter_desc mlx5e_pme_status_desc[] = {
> +       { "module_plug", 0 },
> +       { "module_unplug", 8 },
> +};
> +
> +static const struct counter_desc mlx5e_pme_error_desc[] = {
> +       { "module_pwr_budget_exd", 0 },  /* power budget exceed */
> +       { "module_long_range", 8 },      /* long range for non MLNX cable */
> +       { "module_bus_stuck", 16 },      /* bus stuck (I2C or data shorted) */
> +       { "module_no_eeprom", 24 },      /* no eeprom/retry time out */
> +       { "module_enforce_part", 32 },   /* enforce part number list */
> +       { "module_unknown_id", 40 },     /* unknown identifier */
> +       { "module_high_temp", 48 },      /* high temperature */
> +       { "module_bad_shorted", 56 },    /* bad or shorted cable/module */
> +       { "module_unknown_status", 64 },
> +};
>
>  static void mlx5e_get_drvinfo(struct net_device *dev,
>                               struct ethtool_drvinfo *drvinfo)
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
> index 53e4992d6511..1c867ee973f2 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
> @@ -47,7 +47,7 @@
>
>  struct counter_desc {
>         char            format[ETH_GSTRING_LEN];
> -       int             offset; /* Byte offset */
> +       size_t          offset; /* Byte offset */
>  };
>
>  struct mlx5e_sw_stats {
> @@ -88,49 +88,10 @@ struct mlx5e_sw_stats {
>         u64 link_down_events_phy;
>  };
>
> -static const struct counter_desc sw_stats_desc[] = {
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_packets) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_bytes) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_packets) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_bytes) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_packets) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_bytes) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_inner_packets) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_tso_inner_bytes) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_lro_packets) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_lro_bytes) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_unnecessary) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_none) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_complete) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_unnecessary_inner) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_drop) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_tx) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_tx_full) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial_inner) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_stopped) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_wake) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_dropped) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_xmit_more) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_wqe_err) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_filler) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_buff_alloc_err) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_blks) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_pkts) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_reuse) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_full) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_empty) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_busy) },
> -       { MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, link_down_events_phy) },
> -};
> -
>  struct mlx5e_qcounter_stats {
>         u32 rx_out_of_buffer;
>  };
>
> -static const struct counter_desc q_stats_desc[] = {
> -       { MLX5E_DECLARE_STAT(struct mlx5e_qcounter_stats, rx_out_of_buffer) },
> -};
>
>  #define VPORT_COUNTER_OFF(c) MLX5_BYTE_OFF(query_vport_counter_out, c)
>  #define VPORT_COUNTER_GET(vstats, c) MLX5_GET64(query_vport_counter_out, \
> @@ -140,48 +101,6 @@ struct mlx5e_vport_stats {
>         __be64 query_vport_out[MLX5_ST_SZ_QW(query_vport_counter_out)];
>  };
>
> -static const struct counter_desc vport_stats_desc[] = {
> -       { "rx_vport_unicast_packets",
> -               VPORT_COUNTER_OFF(received_eth_unicast.packets) },
> -       { "rx_vport_unicast_bytes",
> -               VPORT_COUNTER_OFF(received_eth_unicast.octets) },
> -       { "tx_vport_unicast_packets",
> -               VPORT_COUNTER_OFF(transmitted_eth_unicast.packets) },
> -       { "tx_vport_unicast_bytes",
> -               VPORT_COUNTER_OFF(transmitted_eth_unicast.octets) },
> -       { "rx_vport_multicast_packets",
> -               VPORT_COUNTER_OFF(received_eth_multicast.packets) },
> -       { "rx_vport_multicast_bytes",
> -               VPORT_COUNTER_OFF(received_eth_multicast.octets) },
> -       { "tx_vport_multicast_packets",
> -               VPORT_COUNTER_OFF(transmitted_eth_multicast.packets) },
> -       { "tx_vport_multicast_bytes",
> -               VPORT_COUNTER_OFF(transmitted_eth_multicast.octets) },
> -       { "rx_vport_broadcast_packets",
> -               VPORT_COUNTER_OFF(received_eth_broadcast.packets) },
> -       { "rx_vport_broadcast_bytes",
> -               VPORT_COUNTER_OFF(received_eth_broadcast.octets) },
> -       { "tx_vport_broadcast_packets",
> -               VPORT_COUNTER_OFF(transmitted_eth_broadcast.packets) },
> -       { "tx_vport_broadcast_bytes",
> -               VPORT_COUNTER_OFF(transmitted_eth_broadcast.octets) },
> -       { "rx_vport_rdma_unicast_packets",
> -               VPORT_COUNTER_OFF(received_ib_unicast.packets) },
> -       { "rx_vport_rdma_unicast_bytes",
> -               VPORT_COUNTER_OFF(received_ib_unicast.octets) },
> -       { "tx_vport_rdma_unicast_packets",
> -               VPORT_COUNTER_OFF(transmitted_ib_unicast.packets) },
> -       { "tx_vport_rdma_unicast_bytes",
> -               VPORT_COUNTER_OFF(transmitted_ib_unicast.octets) },
> -       { "rx_vport_rdma_multicast_packets",
> -               VPORT_COUNTER_OFF(received_ib_multicast.packets) },
> -       { "rx_vport_rdma_multicast_bytes",
> -               VPORT_COUNTER_OFF(received_ib_multicast.octets) },
> -       { "tx_vport_rdma_multicast_packets",
> -               VPORT_COUNTER_OFF(transmitted_ib_multicast.packets) },
> -       { "tx_vport_rdma_multicast_bytes",
> -               VPORT_COUNTER_OFF(transmitted_ib_multicast.octets) },
> -};
>
>  #define PPORT_802_3_OFF(c) \
>         MLX5_BYTE_OFF(ppcnt_reg, \
> @@ -224,69 +143,6 @@ struct mlx5e_pport_stats {
>         __be64 phy_statistical_counters[MLX5_ST_SZ_QW(ppcnt_reg)];
>  };
>
> -static const struct counter_desc pport_802_3_stats_desc[] = {
> -       { "tx_packets_phy", PPORT_802_3_OFF(a_frames_transmitted_ok) },
> -       { "rx_packets_phy", PPORT_802_3_OFF(a_frames_received_ok) },
> -       { "rx_crc_errors_phy", PPORT_802_3_OFF(a_frame_check_sequence_errors) },
> -       { "tx_bytes_phy", PPORT_802_3_OFF(a_octets_transmitted_ok) },
> -       { "rx_bytes_phy", PPORT_802_3_OFF(a_octets_received_ok) },
> -       { "tx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_xmitted_ok) },
> -       { "tx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_xmitted_ok) },
> -       { "rx_multicast_phy", PPORT_802_3_OFF(a_multicast_frames_received_ok) },
> -       { "rx_broadcast_phy", PPORT_802_3_OFF(a_broadcast_frames_received_ok) },
> -       { "rx_in_range_len_errors_phy", PPORT_802_3_OFF(a_in_range_length_errors) },
> -       { "rx_out_of_range_len_phy", PPORT_802_3_OFF(a_out_of_range_length_field) },
> -       { "rx_oversize_pkts_phy", PPORT_802_3_OFF(a_frame_too_long_errors) },
> -       { "rx_symbol_err_phy", PPORT_802_3_OFF(a_symbol_error_during_carrier) },
> -       { "tx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_transmitted) },
> -       { "rx_mac_control_phy", PPORT_802_3_OFF(a_mac_control_frames_received) },
> -       { "rx_unsupported_op_phy", PPORT_802_3_OFF(a_unsupported_opcodes_received) },
> -       { "rx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_received) },
> -       { "tx_pause_ctrl_phy", PPORT_802_3_OFF(a_pause_mac_ctrl_frames_transmitted) },
> -};
> -
> -static const struct counter_desc pport_2863_stats_desc[] = {
> -       { "rx_discards_phy", PPORT_2863_OFF(if_in_discards) },
> -       { "tx_discards_phy", PPORT_2863_OFF(if_out_discards) },
> -       { "tx_errors_phy", PPORT_2863_OFF(if_out_errors) },
> -};
> -
> -static const struct counter_desc pport_2819_stats_desc[] = {
> -       { "rx_undersize_pkts_phy", PPORT_2819_OFF(ether_stats_undersize_pkts) },
> -       { "rx_fragments_phy", PPORT_2819_OFF(ether_stats_fragments) },
> -       { "rx_jabbers_phy", PPORT_2819_OFF(ether_stats_jabbers) },
> -       { "rx_64_bytes_phy", PPORT_2819_OFF(ether_stats_pkts64octets) },
> -       { "rx_65_to_127_bytes_phy", PPORT_2819_OFF(ether_stats_pkts65to127octets) },
> -       { "rx_128_to_255_bytes_phy", PPORT_2819_OFF(ether_stats_pkts128to255octets) },
> -       { "rx_256_to_511_bytes_phy", PPORT_2819_OFF(ether_stats_pkts256to511octets) },
> -       { "rx_512_to_1023_bytes_phy", PPORT_2819_OFF(ether_stats_pkts512to1023octets) },
> -       { "rx_1024_to_1518_bytes_phy", PPORT_2819_OFF(ether_stats_pkts1024to1518octets) },
> -       { "rx_1519_to_2047_bytes_phy", PPORT_2819_OFF(ether_stats_pkts1519to2047octets) },
> -       { "rx_2048_to_4095_bytes_phy", PPORT_2819_OFF(ether_stats_pkts2048to4095octets) },
> -       { "rx_4096_to_8191_bytes_phy", PPORT_2819_OFF(ether_stats_pkts4096to8191octets) },
> -       { "rx_8192_to_10239_bytes_phy", PPORT_2819_OFF(ether_stats_pkts8192to10239octets) },
> -};
> -
> -static const struct counter_desc pport_phy_statistical_stats_desc[] = {
> -       { "rx_symbol_errors_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
> -       { "rx_corrected_bits_phy", PPORT_PHY_STATISTICAL_OFF(phy_corrected_bits) },
> -};
> -
> -static const struct counter_desc pport_per_prio_traffic_stats_desc[] = {
> -       { "rx_prio%d_bytes", PPORT_PER_PRIO_OFF(rx_octets) },
> -       { "rx_prio%d_packets", PPORT_PER_PRIO_OFF(rx_frames) },
> -       { "tx_prio%d_bytes", PPORT_PER_PRIO_OFF(tx_octets) },
> -       { "tx_prio%d_packets", PPORT_PER_PRIO_OFF(tx_frames) },
> -};
> -
> -static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
> -       /* %s is "global" or "prio{i}" */
> -       { "rx_%s_pause", PPORT_PER_PRIO_OFF(rx_pause) },
> -       { "rx_%s_pause_duration", PPORT_PER_PRIO_OFF(rx_pause_duration) },
> -       { "tx_%s_pause", PPORT_PER_PRIO_OFF(tx_pause) },
> -       { "tx_%s_pause_duration", PPORT_PER_PRIO_OFF(tx_pause_duration) },
> -       { "rx_%s_pause_transition", PPORT_PER_PRIO_OFF(rx_pause_transition) },
> -};
>
>  #define PCIE_PERF_OFF(c) \
>         MLX5_BYTE_OFF(mpcnt_reg, counter_set.pcie_perf_cntrs_grp_data_layout.c)
> @@ -298,11 +154,6 @@ struct mlx5e_pcie_stats {
>         __be64 pcie_perf_counters[MLX5_ST_SZ_QW(mpcnt_reg)];
>  };
>
> -static const struct counter_desc pcie_perf_stats_desc[] = {
> -       { "rx_pci_signal_integrity", PCIE_PERF_OFF(rx_errors) },
> -       { "tx_pci_signal_integrity", PCIE_PERF_OFF(tx_errors) },
> -};
> -
>  struct mlx5e_rq_stats {
>         u64 packets;
>         u64 bytes;
> @@ -325,28 +176,6 @@ struct mlx5e_rq_stats {
>         u64 cache_busy;
>  };
>
> -static const struct counter_desc rq_stats_desc[] = {
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, packets) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, bytes) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_complete) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_unnecessary_inner) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_none) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_drop) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_tx) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_tx_full) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_packets) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_bytes) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, wqe_err) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, mpwqe_filler) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, buff_alloc_err) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_blks) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_pkts) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_reuse) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_full) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_empty) },
> -       { MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_busy) },
> -};
> -
>  struct mlx5e_sq_stats {
>         /* commonly accessed in data path */
>         u64 packets;
> @@ -365,22 +194,6 @@ struct mlx5e_sq_stats {
>         u64 dropped;
>  };
>
> -static const struct counter_desc sq_stats_desc[] = {
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, packets) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, bytes) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_packets) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_bytes) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_inner_packets) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, tso_inner_bytes) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, csum_partial_inner) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, nop) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, csum_none) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, stopped) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, wake) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, dropped) },
> -       { MLX5E_DECLARE_TX_STAT(struct mlx5e_sq_stats, xmit_more) },
> -};
> -
>  #define NUM_SW_COUNTERS                        ARRAY_SIZE(sw_stats_desc)
>  #define NUM_Q_COUNTERS                 ARRAY_SIZE(q_stats_desc)
>  #define NUM_VPORT_COUNTERS             ARRAY_SIZE(vport_stats_desc)
> @@ -416,21 +229,4 @@ struct mlx5e_stats {
>         struct mlx5e_pcie_stats pcie;
>  };
>
> -static const struct counter_desc mlx5e_pme_status_desc[] = {
> -       { "module_plug", 0 },
> -       { "module_unplug", 8 },
> -};
> -
> -static const struct counter_desc mlx5e_pme_error_desc[] = {
> -       { "module_pwr_budget_exd", 0 },  /* power budget exceed */
> -       { "module_long_range", 8 },      /* long range for non MLNX cable */
> -       { "module_bus_stuck", 16 },      /* bus stuck (I2C or data shorted) */
> -       { "module_no_eeprom", 24 },      /* no eeprom/retry time out */
> -       { "module_enforce_part", 32 },   /* enforce part number list */
> -       { "module_unknown_id", 40 },     /* unknown identifier */
> -       { "module_high_temp", 48 },      /* high temperature */
> -       { "module_bad_shorted", 56 },    /* bad or shorted cable/module */
> -       { "module_unknown_status", 64 },
> -};
> -
>  #endif /* __MLX5_EN_STATS_H__ */
> --
> 2.11.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
