From: =?ISO-8859-1?Q?Fran=E7ois_Baligant?= <francois@baligant.net>
Subject: Help interpreting ethtool -S for tg3 (rx_discards and such)
Date: Thu, 09 Sep 2004 18:09:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4140801F.4050208@baligant.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

We have a tg3 NIC under heavy load (30megabit/s, around 15k to 20k 
packet/sec)

Under 2.6.7, the NIC behaves quite correctly (except errors see below)
Under 2.6.8, the NIC's link will go down after some time and not come up 
again (rx_discards grow more quickly than in 2.6.7)
Under 2.6.9-rc1, the NIC will go down from time to time also but recover 
after 5 seconds and link goes up again (dito)

Should I worry about the errors in ethtool, like rx_discards ? What does 
it mean ? Can i tune something to avoid them ? (netdev backlog?)

Is there any way to lower the amount of interrupt needed to handle this 
load? (it's eating quite a lot of CPU)

Here is ethtool -S under 2.6.7

root# ethtool -S eth1
NIC statistics:
     rx_octets: 965700844
     rx_fragments: 0
     rx_ucast_packets: 828761367
     rx_mcast_packets: 80
     rx_bcast_packets: 4768
     rx_fcs_errors: 0
     rx_align_errors: 0
     rx_xon_pause_rcvd: 0
     rx_xoff_pause_rcvd: 0
     rx_mac_ctrl_rcvd: 0
     rx_xoff_entered: 0
     rx_frame_too_long_errors: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_in_length_errors: 0
     rx_out_length_errors: 0
     rx_64_or_less_octet_packets: 366875287
     rx_65_to_127_octet_packets: 438933359
     rx_128_to_255_octet_packets: 18104208
     rx_256_to_511_octet_packets: 2937651
     rx_512_to_1023_octet_packets: 956801
     rx_1024_to_1522_octet_packets: 958902
     rx_1523_to_2047_octet_packets: 0
     rx_2048_to_4095_octet_packets: 0
     rx_4096_to_8191_octet_packets: 0
     rx_8192_to_9022_octet_packets: 0
     tx_octets: 3659297
     tx_collisions: 0
     tx_xon_sent: 0
     tx_xoff_sent: 0
     tx_flow_control: 0
     tx_mac_errors: 0
     tx_single_collisions: 0
     tx_mult_collisions: 0
     tx_deferred: 0
     tx_excessive_collisions: 0
     tx_late_collisions: 0
     tx_collide_2times: 0
     tx_collide_3times: 0
     tx_collide_4times: 0
     tx_collide_5times: 0
     tx_collide_6times: 0
     tx_collide_7times: 0
     tx_collide_8times: 0
     tx_collide_9times: 0
     tx_collide_10times: 0
     tx_collide_11times: 0
     tx_collide_12times: 0
     tx_collide_13times: 0
     tx_collide_14times: 0
     tx_collide_15times: 0
     tx_ucast_packets: 832632783
     tx_mcast_packets: 5
     tx_bcast_packets: 65
     tx_carrier_sense_errors: 0
     tx_discards: 0
     tx_errors: 0
     dma_writeq_full: 496271
     dma_write_prioq_full: 0
     rxbds_empty: 0
     rx_discards: 157542
     rx_errors: 0
     rx_threshold_hit: 828579298
     dma_readq_full: 71729839
     dma_read_prioq_full: 87219
     tx_comp_queue_full: 53098049
     ring_set_send_prod_index: 763849878
     ring_status_update: 906065223
     nic_irqs: 647367776
     nic_avoided_irqs: 258697447
     nic_tx_threshold_hit: 24570520

root# mpstat 1
Linux 2.6.7-mjb1 (localhost)      09/09/2004

10:58:02 AM  CPU   %user   %nice %system %iowait   %idle    intr/s
10:58:03 AM  all   21.66    0.00   14.65    0.00   63.69  29276.92
10:58:04 AM  all   21.25    0.00   15.00    0.00   63.75  28553.75
10:58:05 AM  all   14.81    0.00   10.49    0.00   74.69  26353.09
10:58:06 AM  all   13.94    0.00   10.91    0.00   75.15  24815.85
10:58:07 AM  all   12.50    0.00   10.12    0.00   77.38  23850.00
10:58:08 AM  all   16.77    0.00    9.58    0.00   73.65  23755.42
10:58:09 AM  all   14.12    0.00    9.41    0.00   76.47  22460.00

root# ethtool -a eth1
Pause parameters for eth1:
Autonegotiate:  off
RX:             off
TX:             off

root# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
