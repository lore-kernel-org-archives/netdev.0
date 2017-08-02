From: crow <crow@linux.org.ba>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Wed, 2 Aug 2017 14:39:23 +0200
Message-ID: <CAG_g8w6mbHZpK5g0Yd2RJuXvN8SA8U=aY+=YCuDBhzpPR2Eb4w@mail.gmail.com>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
 <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com>
 <20170610152741.GB26740@lunn.ch> <CAG_g8w71SWc_X2U9pNWLVheO9Jf4ydPznAVp1x-Y9kwU3qhf1A@mail.gmail.com>
 <20170611152102.GA16021@lunn.ch> <CAG_g8w6iEiJ4V2M1=toWWqi1D7H2_p08ceWsbgZ1=PrEGQ2HkA@mail.gmail.com>
 <CAG_g8w7hEdrwspMsNifZ+m82R_-V5=bxv5oMURWy9PRAZU+hHQ@mail.gmail.com>
 <CAG_g8w4MXgP2P3NcEZAi2zu8Diazirjbf=e4+r17vOE=kwXFSA@mail.gmail.com>
 <CAG_g8w4xD5qY8po09QdqC8w7bgjbmbe_nT4jCbt4Fa3ShWNzew@mail.gmail.com> <1501097541.2401.35.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        "open list:ARM/Amlogic Meson..." <linux-amlogic@lists.infradead.org>
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36703 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdHBMjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 08:39:25 -0400
Received: by mail-it0-f42.google.com with SMTP id 77so23028407itj.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 05:39:25 -0700 (PDT)
In-Reply-To: <1501097541.2401.35.camel@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jerome,

On Wed, Jul 26, 2017 at 9:32 PM, Jerome Brunet <jbrunet@baylibre.com> wrote:
> On Tue, 2017-07-25 at 18:56 +0200, crow wrote:
>> Hi,
>> Today I did test on ArchLinuxArm the Kernel v4.13-rc2. On downloading
>> the linux git source the network will eventually get stalled. Here are
>> the information
>>
>> Over SSH (network works).
>>
>> [root@alarm ~]# uname -a
>> Linux alarm 4.13.0-rc2-1-ARCH #1 SMP Mon Jul 24 20:02:50 MDT 2017
>> aarch64 GNU/Linux
>> [root@alarm ~]# mii-tool -vvv eth0
>> Using SIOCGMIIPHY=0x8947
>> eth0: negotiated 1000baseT-HD flow-control, link ok
>
> [Replying again on the last thread :) ]
> This 1000BaseT Half Duplex looks suspucious if the PHY is supposed to be a
> 10/100Mbps

[Resending without HTML]

I am not sure about that nor I can you answer on that. Today I used
buildroot provided by amlogic (compiled by Khadas Stuff) and there
seems no problem with the network. Here are test Report:

# uname -a
Linux buildroot 3.14.29 #1 SMP PREEMPT Tue Aug 1 15:13:51 CST 2017
aarch64 GNU/Linux

After enabling eth0 I get this information
[ 2729.827557] libphy: set driving length c
[ 2729.827667] libphy: set PLL minimum jitter
[ 2729.907553] libphy: set driving length c
[ 2729.907669] libphy: set PLL minimum jitter
[ 2731.334314] libphy: stmmac-0:08 - Link is Up - 100/Full
[ 2881.916512] tx queueing
[ 2943.916674] tx queueing
[ 3073.916713] tx queueing
[ 3083.916897] tx queueing
[ 3097.916686] tx queueing
[ 3105.916744] tx queueing
[ 3127.916700] tx queueing

(this tx queueing comes all time in Serial Console also during git
clone from linux kernel repository. After stoping traffic over ssh no
this message anymore.)


this info is before opening ssh connection to box and doing git clone.
# ethtool -S eth0
NIC statistics:
     mmc_tx_octetcount_gb: 0
     mmc_tx_framecount_gb: 0
     mmc_tx_broadcastframe_g: 0
     mmc_tx_multicastframe_g: 0
     mmc_tx_64_octets_gb: 0
     mmc_tx_65_to_127_octets_gb: 0
     mmc_tx_128_to_255_octets_gb: 0
     mmc_tx_256_to_511_octets_gb: 0
     mmc_tx_512_to_1023_octets_gb: 0
     mmc_tx_1024_to_max_octets_gb: 0
     mmc_tx_unicast_gb: 0
     mmc_tx_multicast_gb: 0
     mmc_tx_broadcast_gb: 0
     mmc_tx_underflow_error: 0
     mmc_tx_singlecol_g: 0
     mmc_tx_multicol_g: 0
     mmc_tx_deferred: 0
     mmc_tx_latecol: 0
     mmc_tx_exesscol: 0
     mmc_tx_carrier_error: 0
     mmc_tx_octetcount_g: 0
     mmc_tx_framecount_g: 0
     mmc_tx_excessdef: 0
     mmc_tx_pause_frame: 0
     mmc_tx_vlan_frame_g: 0
     mmc_rx_framecount_gb: 27
     mmc_rx_octetcount_gb: 3864
     mmc_rx_octetcount_g: 3864
     mmc_rx_broadcastframe_g: 5
     mmc_rx_multicastframe_g: 0
     mmc_rx_crc_errror: 0
     mmc_rx_align_error: 0
     mmc_rx_run_error: 0
     mmc_rx_jabber_error: 0
     mmc_rx_undersize_g: 0
     mmc_rx_oversize_g: 0
     mmc_rx_64_octets_gb: 7
     mmc_rx_65_to_127_octets_gb: 5
     mmc_rx_128_to_255_octets_gb: 12
     mmc_rx_256_to_511_octets_gb: 3
     mmc_rx_512_to_1023_octets_gb: 0
     mmc_rx_1024_to_max_octets_gb: 0
     mmc_rx_unicast_g: 22
     mmc_rx_length_error: 0
     mmc_rx_autofrangetype: 0
     mmc_rx_pause_frames: 0
     mmc_rx_fifo_overflow: 0
     mmc_rx_vlan_frames_gb: 0
     mmc_rx_watchdog_error: 0
     mmc_rx_ipc_intr_mask: 1073692671
     mmc_rx_ipc_intr: 0
     mmc_rx_ipv4_gd: 17
     mmc_rx_ipv4_hderr: 0
     mmc_rx_ipv4_nopay: 0
     mmc_rx_ipv4_frag: 0
     mmc_rx_ipv4_udsbl: 0
     mmc_rx_ipv4_gd_octets: 2816
     mmc_rx_ipv4_hderr_octets: 0
     mmc_rx_ipv4_nopay_octets: 0
     mmc_rx_ipv4_frag_octets: 0
     mmc_rx_ipv4_udsbl_octets: 0
     mmc_rx_ipv6_gd_octets: 240
     mmc_rx_ipv6_hderr_octets: 0
     mmc_rx_ipv6_nopay_octets: 0
     mmc_rx_ipv6_gd: 3
     mmc_rx_ipv6_hderr: 0
     mmc_rx_ipv6_nopay: 0
     mmc_rx_udp_gd: 15
     mmc_rx_udp_err: 0
     mmc_rx_tcp_gd: 0
     mmc_rx_tcp_err: 0
     mmc_rx_icmp_gd: 5
     mmc_rx_icmp_err: 0
     mmc_rx_udp_gd_octets: 2348
     mmc_rx_udp_err_octets: 0
     mmc_rx_tcp_gd_octets: 0
     mmc_rx_tcp_err_octets: 0
     mmc_rx_icmp_gd_octets: 248
     mmc_rx_icmp_err_octets: 0
     tx_underflow: 0
     tx_carrier: 0
     tx_losscarrier: 0
     vlan_tag: 0
     tx_deferred: 0
     tx_vlan: 0
     tx_jabber: 0
     tx_frame_flushed: 0
     tx_payload_error: 0
     tx_ip_header_error: 0
     rx_desc: 0
     sa_filter_fail: 0
     overflow_error: 0
     ipc_csum_error: 0
     rx_collision: 0
     rx_crc: 0
     dribbling_bit: 0
     rx_length: 0
     rx_mii: 0
     rx_multicast: 0
     rx_gmac_overflow: 0
     rx_watchdog: 0
     da_rx_filter_fail: 0
     sa_rx_filter_fail: 0
     rx_missed_cntr: 0
     rx_overflow_cntr: 0
     rx_vlan: 0
     tx_undeflow_irq: 0
     tx_process_stopped_irq: 0
     tx_jabber_irq: 0
     rx_overflow_irq: 0
     rx_buf_unav_irq: 0
     rx_process_stopped_irq: 0
     rx_watchdog_irq: 0
     tx_early_irq: 0
     fatal_bus_error_irq: 0
     rx_early_irq: 0
     threshold: 64
     tx_pkt_n: 31
     rx_pkt_n: 27
     normal_irq_n: 27
     rx_normal_irq_n: 27
     napi_poll: 27
     tx_normal_irq_n: 0
     tx_clean: 46
     tx_reset_ic_bit: 31
     irq_receive_pmt_irq_n: 0
     mmc_tx_irq_n: 0
     mmc_rx_irq_n: 0
     mmc_rx_csum_offload_irq_n: 0
     irq_tx_path_in_lpi_mode_n: 0
     irq_tx_path_exit_lpi_mode_n: 0
     irq_rx_path_in_lpi_mode_n: 0
     irq_rx_path_exit_lpi_mode_n: 0
     phy_eee_wakeup_error_n: 0
     ip_hdr_err: 0
     ip_payload_err: 0
     ip_csum_bypassed: 0
     ipv4_pkt_rcvd: 0
     ipv6_pkt_rcvd: 0
     rx_msg_type_ext_no_ptp: 0
     rx_msg_type_sync: 0
     rx_msg_type_follow_up: 0
     rx_msg_type_delay_req: 0
     rx_msg_type_delay_resp: 0
     rx_msg_type_pdelay_req: 0
     rx_msg_type_pdelay_resp: 0
     rx_msg_type_pdelay_follow_up: 0
     ptp_frame_type: 0
     ptp_ver: 0
     timestamp_dropped: 0
     av_pkt_rcvd: 0
     av_tagged_pkt_rcvd: 0
     vlan_tag_priority_val: 0
     l3_filter_match: 0
     l4_filter_match: 0
     l3_l4_filter_no_match: 0
     irq_pcs_ane_n: 0
     irq_pcs_link_n: 0
     irq_rgmii_n: 0
# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000f 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0082 40e8 5400 0d80 1000 0000 6400
    fff0 ffff 0000 110a 1407 0000 0e50 105a


>>   registers for MII PHY 8:
>>     1000 782d 0181 4400 01e1 c1e1 000f 2001
>>     ffff ffff ffff ffff ffff ffff ffff ffff
>>     0040 0002 40e8 5400 1c1c 0000 0000 aaaa
>>     fff0 ffff 0000 000a 1407 004a 0000 105a
>>   product info: vendor 00:60:51, model 0 rev 0
>>   basic mode:   autonegotiation enabled
>>   basic status: autonegotiation complete, link ok
>>   capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> 10baseT-FD 10baseT-HD
>>   advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> 10baseT-FD 10baseT-HD
>>   link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> 10baseT-FD 10baseT-HD
>> [root@alarm ~]# ethtool -S eth0
>> NIC statistics:
>>      mmc_tx_octetcount_gb: 0
>>      mmc_tx_framecount_gb: 0
>>      mmc_tx_broadcastframe_g: 0
>>      mmc_tx_multicastframe_g: 0
>>      mmc_tx_64_octets_gb: 0
>>      mmc_tx_65_to_127_octets_gb: 0
>>      mmc_tx_128_to_255_octets_gb: 0
>>      mmc_tx_256_to_511_octets_gb: 0
>>      mmc_tx_512_to_1023_octets_gb: 0
>>      mmc_tx_1024_to_max_octets_gb: 0
>>      mmc_tx_unicast_gb: 0
>>      mmc_tx_multicast_gb: 0
>>      mmc_tx_broadcast_gb: 0
>>      mmc_tx_underflow_error: 0
>>      mmc_tx_singlecol_g: 0
>>      mmc_tx_multicol_g: 0
>>      mmc_tx_deferred: 0
>>      mmc_tx_latecol: 0
>>      mmc_tx_exesscol: 0
>>      mmc_tx_carrier_error: 0
>>      mmc_tx_octetcount_g: 0
>>      mmc_tx_framecount_g: 0
>>      mmc_tx_excessdef: 0
>>      mmc_tx_pause_frame: 0
>>      mmc_tx_vlan_frame_g: 0
>>      mmc_rx_framecount_gb: 133
>>      mmc_rx_octetcount_gb: 16646
>>      mmc_rx_octetcount_g: 16646
>>      mmc_rx_broadcastframe_g: 9
>>      mmc_rx_multicastframe_g: 22
>>      mmc_rx_crc_error: 0
>>      mmc_rx_align_error: 0
>>      mmc_rx_run_error: 0
>>      mmc_rx_jabber_error: 0
>>      mmc_rx_undersize_g: 0
>>      mmc_rx_oversize_g: 0
>>      mmc_rx_64_octets_gb: 45
>>      mmc_rx_65_to_127_octets_gb: 64
>>      mmc_rx_128_to_255_octets_gb: 13
>>      mmc_rx_256_to_511_octets_gb: 7
>>      mmc_rx_512_to_1023_octets_gb: 4
>>      mmc_rx_1024_to_max_octets_gb: 0
>>      mmc_rx_unicast_g: 102
>>      mmc_rx_length_error: 0
>>      mmc_rx_autofrangetype: 0
>>      mmc_rx_pause_frames: 0
>>      mmc_rx_fifo_overflow: 0
>>      mmc_rx_vlan_frames_gb: 0
>>      mmc_rx_watchdog_error: 0
>>      mmc_rx_ipc_intr_mask: 1073692671
>>      mmc_rx_ipc_intr: 0
>>      mmc_rx_ipv4_gd: 117
>>      mmc_rx_ipv4_hderr: 0
>>      mmc_rx_ipv4_nopay: 0
>>      mmc_rx_ipv4_frag: 0
>>      mmc_rx_ipv4_udsbl: 0
>>      mmc_rx_ipv4_gd_octets: 12585
>>      mmc_rx_ipv4_hderr_octets: 0
>>      mmc_rx_ipv4_nopay_octets: 0
>>      mmc_rx_ipv4_frag_octets: 0
>>      mmc_rx_ipv4_udsbl_octets: 0
>>      mmc_rx_ipv6_gd_octets: 104
>>      mmc_rx_ipv6_hderr_octets: 0
>>      mmc_rx_ipv6_nopay_octets: 0
>>      mmc_rx_ipv6_gd: 1
>>      mmc_rx_ipv6_hderr: 0
>>      mmc_rx_ipv6_nopay: 0
>>      mmc_rx_udp_gd: 31
>>      mmc_rx_udp_err: 0
>>      mmc_rx_tcp_gd: 85
>>      mmc_rx_tcp_err: 0
>>      mmc_rx_icmp_gd: 2
>>      mmc_rx_icmp_err: 0
>>      mmc_rx_udp_gd_octets: 2963
>>      mmc_rx_udp_err_octets: 0
>>      mmc_rx_tcp_gd_octets: 7254
>>      mmc_rx_tcp_err_octets: 0
>>      mmc_rx_icmp_gd_octets: 92
>>      mmc_rx_icmp_err_octets: 0
>>      tx_underflow: 0
>>      tx_carrier: 0
>>      tx_losscarrier: 0
>>      vlan_tag: 0
>>      tx_deferred: 0
>>      tx_vlan: 0
>>      tx_jabber: 0
>>      tx_frame_flushed: 0
>>      tx_payload_error: 0
>>      tx_ip_header_error: 0
>>      rx_desc: 0
>>      sa_filter_fail: 0
>>      overflow_error: 0
>>      ipc_csum_error: 0
>>      rx_collision: 0
>>      rx_crc_errors: 0
>>      dribbling_bit: 0
>>      rx_length: 0
>>      rx_mii: 0
>>      rx_multicast: 0
>>      rx_gmac_overflow: 0
>>      rx_watchdog: 0
>>      da_rx_filter_fail: 0
>>      sa_rx_filter_fail: 0
>>      rx_missed_cntr: 0
>>      rx_overflow_cntr: 0
>>      rx_vlan: 0
>>      tx_undeflow_irq: 0
>>      tx_process_stopped_irq: 0
>>      tx_jabber_irq: 0
>>      rx_overflow_irq: 0
>>      rx_buf_unav_irq: 0
>>      rx_process_stopped_irq: 0
>>      rx_watchdog_irq: 0
>>      tx_early_irq: 0
>>      fatal_bus_error_irq: 0
>>      rx_early_irq: 0
>>      threshold: 1
>>      tx_pkt_n: 83
>>      rx_pkt_n: 133
>>      normal_irq_n: 130
>>      rx_normal_irq_n: 129
>>      napi_poll: 130
>>      tx_normal_irq_n: 1
>>      tx_clean: 192
>>      tx_set_ic_bit: 1
>>      irq_receive_pmt_irq_n: 0
>>      mmc_tx_irq_n: 0
>>      mmc_rx_irq_n: 0
>>      mmc_rx_csum_offload_irq_n: 0
>>      irq_tx_path_in_lpi_mode_n: 72
>>      irq_tx_path_exit_lpi_mode_n: 72
>>      irq_rx_path_in_lpi_mode_n: 0
>>      irq_rx_path_exit_lpi_mode_n: 0
>>      phy_eee_wakeup_error_n: 65535
>>      ip_hdr_err: 0
>>      ip_payload_err: 0
>>      ip_csum_bypassed: 0
>>      ipv4_pkt_rcvd: 0
>>      ipv6_pkt_rcvd: 0
>>      no_ptp_rx_msg_type_ext: 0
>>      ptp_rx_msg_type_sync: 0
>>      ptp_rx_msg_type_follow_up: 0
>>      ptp_rx_msg_type_delay_req: 0
>>      ptp_rx_msg_type_delay_resp: 0
>>      ptp_rx_msg_type_pdelay_req: 0
>>      ptp_rx_msg_type_pdelay_resp: 0
>>      ptp_rx_msg_type_pdelay_follow_up: 0
>>      ptp_rx_msg_type_announce: 0
>>      ptp_rx_msg_type_management: 0
>>      ptp_rx_msg_pkt_reserved_type: 0
>>      ptp_frame_type: 0
>>      ptp_ver: 0
>>      timestamp_dropped: 0
>>      av_pkt_rcvd: 0
>>      av_tagged_pkt_rcvd: 0
>>      vlan_tag_priority_val: 0
>>      l3_filter_match: 0
>>      l4_filter_match: 0
>>      l3_l4_filter_no_match: 0
>>      irq_pcs_ane_n: 0
>>      irq_pcs_link_n: 0
>>      irq_rgmii_n: 0
>>      mtl_tx_status_fifo_full: 0
>>      mtl_tx_fifo_not_empty: 0
>>      mmtl_fifo_ctrl: 0
>>      mtl_tx_fifo_read_ctrl_write: 0
>>      mtl_tx_fifo_read_ctrl_wait: 0
>>      mtl_tx_fifo_read_ctrl_read: 0
>>      mtl_tx_fifo_read_ctrl_idle: 0
>>      mac_tx_in_pause: 0
>>      mac_tx_frame_ctrl_xfer: 0
>>      mac_tx_frame_ctrl_idle: 0
>>      mac_tx_frame_ctrl_wait: 0
>>      mac_tx_frame_ctrl_pause: 0
>>      mac_gmii_tx_proto_engine: 0
>>      mtl_rx_fifo_fill_level_full: 0
>>      mtl_rx_fifo_fill_above_thresh: 0
>>      mtl_rx_fifo_fill_below_thresh: 0
>>      mtl_rx_fifo_fill_level_empty: 0
>>      mtl_rx_fifo_read_ctrl_flush: 0
>>      mtl_rx_fifo_read_ctrl_read_data: 0
>>      mtl_rx_fifo_read_ctrl_status: 0
>>      mtl_rx_fifo_read_ctrl_idle: 0
>>      mtl_rx_fifo_ctrl_active: 0
>>      mac_rx_frame_ctrl_fifo: 0
>>      mac_gmii_rx_proto_engine: 0
>>      tx_tso_frames: 0
>>      tx_tso_nfrags: 0
>> [root@alarm ~]#
>>
>>
>>
>>
>> [root@alarm opt]# git clone
>> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
>> Cloning into 'linux-stable'...
>> remote: Counting objects: 6071472, done.
>> remote: Compressing objects: 100% (961861/961861), done.
>> Receiving objects:   0% (22798/6071472), 9.12 MiB | 3.47 MiB/s
>>
>>
>>
>> Over serial console:
>> journalctl -f
>> alarm systemd-timesyncd[256]: Timed out waiting for reply from
>> 144.76.197.108:123 (2.arch.pool.ntp.org).
>>
>> [root@alarm ~]# ping -c3 8.8.8.8
>> PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
>> From 10.8.8.6 icmp_seq=1 Destination Host Unreachable
>> From 10.8.8.6 icmp_seq=2 Destination Host Unreachable
>> From 10.8.8.6 icmp_seq=3 Destination Host Unreachable
>>
>> --- 8.8.8.8 ping statistics ---
>> 3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2047ms
>> pipe 3
>> [root@alarm ~]#
>> [root@alarm ~]# mii-tool -vvv eth0
>> Using SIOCGMIIPHY=0x8947
>> eth0: negotiated 1000baseT-HD flow-control, link ok
>>   registers for MII PHY 8:
>>     1000 782d 0181 4400 01e1 c1e1 000d 2001
>>     ffff ffff ffff ffff ffff ffff ffff ffff
>>     0040 0002 40e8 5400 1c1c 0000 0000 aaaa
>>     fff0 ffff 0000 000a 1407 0000 0000 105a
>>   product info: vendor 00:60:51, model 0 rev 0
>>   basic mode:   autonegotiation enabled
>>   basic status: autonegotiation complete, link ok
>>   capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> 10baseT-FD 10baseT-HD
>>   advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> 10baseT-FD 10baseT-HD
>>   link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> 10baseT-FD 10baseT-HD
>> [root@alarm ~]# ethtool -S eth0
>> NIC statistics:
>>      mmc_tx_octetcount_gb: 0
>>      mmc_tx_framecount_gb: 0
>>      mmc_tx_broadcastframe_g: 0
>>      mmc_tx_multicastframe_g: 0
>>      mmc_tx_64_octets_gb: 0
>>      mmc_tx_65_to_127_octets_gb: 0
>>      mmc_tx_128_to_255_octets_gb: 0
>>      mmc_tx_256_to_511_octets_gb: 0
>>      mmc_tx_512_to_1023_octets_gb: 0
>>      mmc_tx_1024_to_max_octets_gb: 0
>>      mmc_tx_unicast_gb: 0
>>      mmc_tx_multicast_gb: 0
>>      mmc_tx_broadcast_gb: 0
>>      mmc_tx_underflow_error: 0
>>      mmc_tx_singlecol_g: 0
>>      mmc_tx_multicol_g: 0
>>      mmc_tx_deferred: 0
>>      mmc_tx_latecol: 0
>>      mmc_tx_exesscol: 0
>>      mmc_tx_carrier_error: 0
>>      mmc_tx_octetcount_g: 0
>>      mmc_tx_framecount_g: 0
>>      mmc_tx_excessdef: 0
>>      mmc_tx_pause_frame: 0
>>      mmc_tx_vlan_frame_g: 0
>>      mmc_rx_framecount_gb: 14959
>>      mmc_rx_octetcount_gb: 20761536
>>      mmc_rx_octetcount_g: 20761536
>>      mmc_rx_broadcastframe_g: 22
>>      mmc_rx_multicastframe_g: 64
>>      mmc_rx_crc_error: 0
>>      mmc_rx_align_error: 0
>>      mmc_rx_run_error: 0
>>      mmc_rx_jabber_error: 0
>>      mmc_rx_undersize_g: 0
>>      mmc_rx_oversize_g: 0
>>      mmc_rx_64_octets_gb: 495
>>      mmc_rx_65_to_127_octets_gb: 658
>>      mmc_rx_128_to_255_octets_gb: 73
>>      mmc_rx_256_to_511_octets_gb: 63
>>      mmc_rx_512_to_1023_octets_gb: 124
>>      mmc_rx_1024_to_max_octets_gb: 13546
>>      mmc_rx_unicast_g: 14873
>>      mmc_rx_length_error: 0
>>      mmc_rx_autofrangetype: 0
>>      mmc_rx_pause_frames: 0
>>      mmc_rx_fifo_overflow: 0
>>      mmc_rx_vlan_frames_gb: 0
>>      mmc_rx_watchdog_error: 0
>>      mmc_rx_ipc_intr_mask: 2147385342
>>      mmc_rx_ipc_intr: 0
>>      mmc_rx_ipv4_gd: 14725
>>      mmc_rx_ipv4_hderr: 0
>>      mmc_rx_ipv4_nopay: 0
>>      mmc_rx_ipv4_frag: 0
>>      mmc_rx_ipv4_udsbl: 0
>>      mmc_rx_ipv4_gd_octets: 20476749
>>      mmc_rx_ipv4_hderr_octets: 0
>>      mmc_rx_ipv4_nopay_octets: 0
>>      mmc_rx_ipv4_frag_octets: 0
>>      mmc_rx_ipv4_udsbl_octets: 0
>>      mmc_rx_ipv6_gd_octets: 312
>>      mmc_rx_ipv6_hderr_octets: 0
>>      mmc_rx_ipv6_nopay_octets: 0
>>      mmc_rx_ipv6_gd: 3
>>      mmc_rx_ipv6_hderr: 0
>>      mmc_rx_ipv6_nopay: 0
>>      mmc_rx_udp_gd: 51
>>      mmc_rx_udp_err: 0
>>      mmc_rx_tcp_gd: 14673
>>      mmc_rx_tcp_err: 0
>>      mmc_rx_icmp_gd: 4
>>      mmc_rx_icmp_err: 0
>>      mmc_rx_udp_gd_octets: 3924
>>      mmc_rx_udp_err_octets: 0
>>      mmc_rx_tcp_gd_octets: 20178297
>>      mmc_rx_tcp_err_octets: 0
>>      mmc_rx_icmp_gd_octets: 220
>>      mmc_rx_icmp_err_octets: 0
>>      tx_underflow: 0
>>      tx_carrier: 0
>>      tx_losscarrier: 0
>>      vlan_tag: 0
>>      tx_deferred: 0
>>      tx_vlan: 0
>>      tx_jabber: 0
>>      tx_frame_flushed: 0
>>      tx_payload_error: 0
>>      tx_ip_header_error: 0
>>      rx_desc: 0
>>      sa_filter_fail: 0
>>      overflow_error: 0
>>      ipc_csum_error: 0
>>      rx_collision: 0
>>      rx_crc_errors: 0
>>      dribbling_bit: 0
>>      rx_length: 0
>>      rx_mii: 0
>>      rx_multicast: 0
>>      rx_gmac_overflow: 0
>>      rx_watchdog: 0
>>      da_rx_filter_fail: 0
>>      sa_rx_filter_fail: 0
>>      rx_missed_cntr: 0
>>      rx_overflow_cntr: 0
>>      rx_vlan: 0
>>      tx_undeflow_irq: 0
>>      tx_process_stopped_irq: 0
>>      tx_jabber_irq: 0
>>      rx_overflow_irq: 0
>>      rx_buf_unav_irq: 0
>>      rx_process_stopped_irq: 0
>>      rx_watchdog_irq: 0
>>      tx_early_irq: 0
>>      fatal_bus_error_irq: 0
>>      rx_early_irq: 6
>>      threshold: 1
>>      tx_pkt_n: 3709
>>      rx_pkt_n: 12926
>>      normal_irq_n: 4594
>>      rx_normal_irq_n: 4537
>>      napi_poll: 4597
>>      tx_normal_irq_n: 57
>>      tx_clean: 5109
>>      tx_set_ic_bit: 59
>>      irq_receive_pmt_irq_n: 0
>>      mmc_tx_irq_n: 0
>>      mmc_rx_irq_n: 0
>>      mmc_rx_csum_offload_irq_n: 0
>>      irq_tx_path_in_lpi_mode_n: 2921
>>      irq_tx_path_exit_lpi_mode_n: 2920
>>      irq_rx_path_in_lpi_mode_n: 0
>>      irq_rx_path_exit_lpi_mode_n: 0
>>      phy_eee_wakeup_error_n: 65535
>>      ip_hdr_err: 0
>>      ip_payload_err: 0
>>      ip_csum_bypassed: 0
>>      ipv4_pkt_rcvd: 0
>>      ipv6_pkt_rcvd: 0
>>      no_ptp_rx_msg_type_ext: 0
>>      ptp_rx_msg_type_sync: 0
>>      ptp_rx_msg_type_follow_up: 0
>>      ptp_rx_msg_type_delay_req: 0
>>      ptp_rx_msg_type_delay_resp: 0
>>      ptp_rx_msg_type_pdelay_req: 0
>>      ptp_rx_msg_type_pdelay_resp: 0
>>      ptp_rx_msg_type_pdelay_follow_up: 0
>>      ptp_rx_msg_type_announce: 0
>>      ptp_rx_msg_type_management: 0
>>      ptp_rx_msg_pkt_reserved_type: 0
>>      ptp_frame_type: 0
>>      ptp_ver: 0
>>      timestamp_dropped: 0
>>      av_pkt_rcvd: 0
>>      av_tagged_pkt_rcvd: 0
>>      vlan_tag_priority_val: 0
>>      l3_filter_match: 0
>>      l4_filter_match: 0
>>      l3_l4_filter_no_match: 0
>>      irq_pcs_ane_n: 0
>>      irq_pcs_link_n: 0
>>      irq_rgmii_n: 0
>>      mtl_tx_status_fifo_full: 0
>>      mtl_tx_fifo_not_empty: 0
>>      mmtl_fifo_ctrl: 0
>>      mtl_tx_fifo_read_ctrl_write: 0
>>      mtl_tx_fifo_read_ctrl_wait: 0
>>      mtl_tx_fifo_read_ctrl_read: 0
>>      mtl_tx_fifo_read_ctrl_idle: 0
>>      mac_tx_in_pause: 0
>>      mac_tx_frame_ctrl_xfer: 0
>>      mac_tx_frame_ctrl_idle: 0
>>      mac_tx_frame_ctrl_wait: 0
>>      mac_tx_frame_ctrl_pause: 0
>>      mac_gmii_tx_proto_engine: 0
>>      mtl_rx_fifo_fill_level_full: 0
>>      mtl_rx_fifo_fill_above_thresh: 0
>>      mtl_rx_fifo_fill_below_thresh: 0
>>      mtl_rx_fifo_fill_level_empty: 0
>>      mtl_rx_fifo_read_ctrl_flush: 0
>>      mtl_rx_fifo_read_ctrl_read_data: 0
>>      mtl_rx_fifo_read_ctrl_status: 0
>>      mtl_rx_fifo_read_ctrl_idle: 0
>>      mtl_rx_fifo_ctrl_active: 0
>>      mac_rx_frame_ctrl_fifo: 0
>>      mac_gmii_rx_proto_engine: 0
>>      tx_tso_frames: 0
>>      tx_tso_nfrags: 0
>> [root@alarm ~]#
>> [root@alarm ~]# ifconfig eth0 down && ifconfig eth0 up
>> Meson GXL Internal PHY 0.e40908ff:08: attached PHY driver [Meson GXL
>> Internal PHY] (mii_bus:phy_addr=0.e40908ff:08, irq=-1)
>> meson8b-dwmac c9410000.ethernet eth0: PTP not supported by HW
>> meson8b-dwmac c9410000.ethernet eth0: Link is Up - 100Mbps/Full - flow
>> control off
>> [root@alarm ~]#
>>
>>
>>
>> whole dmesg [1]. there are some messages like: mdio-mux-mmioreg
>> c883455c.eth-phy-mux: failed to register mdio-mux bus
>> /soc/periphs@c8834000/eth-phy-mux
>>
>> [1] https://defuse.ca/b/s2NpyJlw
>>
>> Regards,
>>
>>
>> On Tue, Jun 27, 2017 at 7:14 PM, crow <crow@linux.org.ba> wrote:
>> > Hi,
>> > There are other user reporting same issue while using mainline kernel
>> > but using Ubuntu, so this is for sure not Distribution related. For me
>> > see the [0]. I hope someone would get time after 4.12 release to try
>> > fix this issue.
>> >
>> > Regards,
>> >
>> > [0] http://forum.khadas.com/t/ubuntu-server-rom-linux-mainline-v170624-pre-a
>> > lpha-version-emmc-installation/803/12
>> >
>> > On Thu, Jun 15, 2017 at 4:40 PM, crow <crow@linux.org.ba> wrote:
>> > > Hi,
>> > >
>> > > On Sun, Jun 11, 2017 at 7:03 PM, crow <crow@linux.org.ba> wrote:
>> > > > Hi Andrew,
>> > > >
>> > > > On Sun, Jun 11, 2017 at 5:21 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > > > > > Thank your for the suggestion, and thanks Martin to explaining me
>> > > > > > over
>> > > > > > IRC what actually I should do.
>> > > > > >
>> > > > > > I recompiled mainline kernel 4.12-rc4 with the Amlogic driver:
>> > > > > > replaced drivers/net/phy/meson-gxl.c with
>> > > > > > https://github.com/khadas/linux/blob/ubuntu-4.9/drivers/amlogic/ethe
>> > > > > > rnet/phy/amlogic.c
>> > > > > >
>> > > > > > But this did not solve the issue. As soon as i start git clone i
>> > > > > > lose
>> > > > > > network connection to device (no session timeout/disconnect this
>> > > > > > time,
>> > > > > > but I am unable to reconnect over SSH or to get OK ping replay
>> > > > > > back).
>> > > >
>> > > > 1) First problem reported I can't reproduce anymore, every reboot/cold
>> > > > boot with mainline kernel the Ethernet speed is detected as
>> > > > "100Mbps/Full" , but as seen in first post there was this issue.
>> > >
>> > > Once I did setup u-boot to have network in u-boot and did just an ping
>> > > to activate network. And after boot Ethernet was detected as 10Mbps.
>> > > But again was not able to reproduce it. I double check that I have 5E
>> > > cable.
>> > >
>> > > in u-boot Ethernet is detected as below
>> > > kvim#ping x.x.x.x
>> > > Speed: 100, full duplex
>> > > Using dwmac.c9410000 device
>> > > host x.x.x.x is alive
>> > > kvim#
>> > >
>> > > then I let ArchLinuxArm to boot and found out I can't connect to
>> > > device over SSH. Check over serial console and found:
>> > >
>> > > # dmesg | tail -n 10
>> > > [    8.334790] meson8b-dwmac c9410000.ethernet eth0: device MAC
>> > > address 00:15:18:01:81:31
>> > > [    8.436668] Meson GXL Internal PHY 0.e40908ff:08: attached PHY
>> > > driver [Meson GXL Internal PHY] (mii_bus:phy_addr=0.e40908ff:08,
>> > > irq=-1)
>> > > [    8.535171] meson8b-dwmac c9410000.ethernet eth0: PTP not supported by
>> > > HW
>> > > [   10.225264] brcmfmac: brcmf_c_preinit_dcmds: Firmware version =
>> > > wl0: Mar  1 2015 07:29:38 version 7.45.18 (r538002) FWID 01-6a2c8ad4
>> > > [   10.635703] meson8b-dwmac c9410000.ethernet eth0: Link is Up -
>> > > 10Mbps/Half - flow control off
>> > > # uname -a
>> > > Linux khadasvimpro 4.12.0-rc4-3-ARCH #1 SMP Thu Jun 8 00:17:20 CEST
>> > > 2017 aarch64 GNU/Linux
>> > > #
>> > > # mii-tool -vvv eth0
>> > > Using SIOCGMIIPHY=0x8947
>> > > eth0: no autonegotiation,, link ok
>> > >   registers for MII PHY 8:
>> > >     1000 782d 0181 4400 01e1 0001 0005 2001
>> > >     ffff ffff ffff ffff ffff ffff ffff ffff
>> > >     0040 0002 40e8 5400 1c1c 0000 0000 aaaa
>> > >     fff0 ffff 0000 000a 1407 0040 0000 105a
>> > >   product info: vendor 00:60:51, model 0 rev 0
>> > >   basic mode:   autonegotiation enabled
>> > >   basic status: autonegotiation complete, link ok
>> > >   capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> > > 10baseT-FD 10baseT-HD
>> > >   advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> > > 10baseT-FD 10baseT-HD
>> > > #
>> > > # ifconfig eth0 down && ifconfig eth0 up
>> > > [ 1972.596690] Meson GXL Internal PHY 0.e40908ff:08: attached PHY
>> > > driver [Meson GXL Internal PHY] (mii_bus:phy_addr=0.e40908ff:08,
>> > > irq=-1)
>> > > [ 1972.704156] meson8b-dwmac c9410000.ethernet eth0: PTP not supported by
>> > > HW
>> > > [ 1974.795698] meson8b-dwmac c9410000.ethernet eth0: Link is Up -
>> > > 100Mbps/Full - flow control off
>> > > #
>> > > # mii-tool -vvv eth0
>> > > Using SIOCGMIIPHY=0x8947
>> > > eth0: negotiated 1000baseT-HD flow-control, link ok
>> > >   registers for MII PHY 8:
>> > >     1000 782d 0181 4400 01e1 c1e1 000f 2001
>> > >     ffff ffff ffff ffff ffff ffff ffff ffff
>> > >     0040 0002 40e8 5400 1c1c 0000 0000 aaaa
>> > >     fff0 ffff 0000 020a 1407 00ca 0000 105a
>> > >   product info: vendor 00:60:51, model 0 rev 0
>> > >   basic mode:   autonegotiation enabled
>> > >   basic status: autonegotiation complete, link ok
>> > >   capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> > > 10baseT-FD 10baseT-HD
>> > >   advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> > > 10baseT-FD 10baseT-HD
>> > >   link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>> > > 10baseT-FD 10baseT-HD
>> > > #
>> > >
>> > > 2) see below
>> > > > 2) see below
>> > > >
>> > > > > So this shows it is more than a PHY problem. The Ethernet MAC driver
>> > > > > is probably also part of the problem.
>> > > >
>> > > > There are some stmmac fixes [1] in soon to be rc5, compiled current
>> > > > master (without amlogic.c) with the fixes but for me the issue still
>> > > > persist. I will compile once released rc5 with amlogic.c and report
>> > > > back.
>> > > >
>> > > > > Are there any mainline kernels which work O.K?
>> > > >
>> > > > Khadas VIM support was added in 4.12-rc1. And I did test all four rc's
>> > > > but without success.
>> > >
>> > > I did test many Kernel builds but all test have failed when
>> > > downloading bigger files / doing git clone.
>> > > As Martin Blumenstingl suggested I start with first commit where
>> > > Khadas VIM support was added [0]. Then also Neil Armstrong suggested
>> > > [1]. Then all 4.12-rc1 - rc5.
>> > > Martin Blumenstingl have also found himself that: "I can reproduce the
>> > > Ethernet problem (tried downloading a 1GiB test file from leaseweb,
>> > > network got stuck after downloading ~70 MiB)". He suggested that I
>> > > should "play with the settings on your switch (disable jumbo frames,
>> > > etc.) to rule out the "exotic" stuff?". Well other device (x86_64)
>> > > connected on this same Switch port does not have any problem
>> > > downloading big files or doing git clone, as well as Khadas VIM with
>> > > Amlogic kernel. Also jumbo frames are not enabled, switch does have
>> > > only standard settings.
>> > >
>> > > I also get questioned which qdisc I use:
>> > > And it seems I am already using fq_codel (ArchLinuxArm uses systemd):
>> > > $ tc -s -p qdisc
>> > > qdisc noqueue 0: dev lo root refcnt 2
>> > >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>> > >  backlog 0b 0p requeues 0
>> > > qdisc mq 0: dev eth0 root
>> > >  Sent 7382956 bytes 60703 pkt (dropped 0, overlimits 0 requeues 18)
>> > >  backlog 0b 0p requeues 18
>> > > qdisc fq_codel 0: dev eth0 parent :1 limit 10240p flows 1024 quantum
>> > > 1514 target 5.0ms interval 100.0ms memory_limit 32Mb ecn
>> > >  Sent 7382956 bytes 60703 pkt (dropped 0, overlimits 0 requeues 18)
>> > >  backlog 0b 0p requeues 18
>> > >   maxpacket 54 drop_overlimit 0 new_flow_count 14 ecn_mark 0
>> > >   new_flows_len 0 old_flows_len 0
>> > > $ pacman -Qi systemd
>> > > Name            : systemd
>> > > Version         : 232-8
>> > > Description     : system and service manager
>> > > Architecture    : aarch64
>> > > ...
>> > > $
>> > >
>> > >
>> > > Regards,
>> > >
>> > > > >     Andrew
>> > > >
>> > > > [1] https://github.com/torvalds/linux/commit/426849e6611f2092553f8d53372
>> > > > ae310818a6292
>> > >
>> > > [0] https://github.com/torvalds/linux/commit/e15d2774b8c096f116bf7192b37e8
>> > > 652da71369e
>> > > [1] https://kernel.googlesource.com/pub/scm/linux/kernel/git/khilman/linux
>> > > -amlogic/+/v4.12/integ
>>

Regards,
