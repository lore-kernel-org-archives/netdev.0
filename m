From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: ixgbe - problem with packet/bytes count on all queues
Date: Sun, 18 Apr 2010 11:14:02 +0200
Message-ID: <4BCACD5A.6070809@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:55377 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755277Ab0DRJOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 05:14:04 -0400
Received: from unknown (HELO [192.168.1.101]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp2.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 18 Apr 2010 09:14:01 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I want to ask is this a normal behavior of ixgb driver and 82598EB nic.
look for tx_queue_7 stats:
  ethtool -S eth2
NIC statistics:
      rx_packets: 35103252
      tx_packets: 1770371731
      rx_bytes: 3602052416
      tx_bytes: 1369778276
      rx_pkts_nic: 138121006018
      tx_pkts_nic: 122033163226
      rx_bytes_nic: 101484528847981
      tx_bytes_nic: 92258799092069
      lsc_int: 1
      tx_busy: 0
      non_eop_descs: 0
      rx_errors: 0
      tx_errors: 0
      rx_dropped: 0
      tx_dropped: 0
      multicast: 490226
      broadcast: 124104912
      rx_no_buffer_count: 0
      collisions: 0
      rx_over_errors: 0
      rx_crc_errors: 0
      rx_frame_errors: 0
      hw_rsc_aggregated: 0
      hw_rsc_flushed: 0
      fdir_match: 0
      fdir_miss: 0
      rx_fifo_errors: 0
      rx_missed_errors: 0
      tx_aborted_errors: 0
      tx_carrier_errors: 0
      tx_fifo_errors: 0
      tx_heartbeat_errors: 0
      tx_timeout_count: 0
      tx_restart_queue: 111130
      rx_long_length_errors: 38599
      rx_short_length_errors: 0
      tx_flow_control_xon: 0
      rx_flow_control_xon: 0
      tx_flow_control_xoff: 0
      rx_flow_control_xoff: 0
      rx_csum_offload_errors: 1554191
      alloc_rx_page_failed: 0
      alloc_rx_buff_failed: 0
      rx_no_dma_resources: 0
      tx_queue_0_packets: 108685351623
      tx_queue_0_bytes: 79701402025544
      tx_queue_1_packets: 3988024698
      tx_queue_1_bytes: 3353530467775
      tx_queue_2_packets: 1893305707
      tx_queue_2_bytes: 1705357186034
      tx_queue_3_packets: 1787852613
      tx_queue_3_bytes: 1518632482370
      tx_queue_4_packets: 1843108684
      tx_queue_4_bytes: 1641474602504
      tx_queue_5_packets: 1882637467
      tx_queue_5_bytes: 1629905766993
      tx_queue_6_packets: 1952759802
      tx_queue_6_bytes: 1680666591771
      tx_queue_7_packets: 0
      tx_queue_7_bytes: 0
      rx_queue_0_packets: 17361735592
      rx_queue_0_bytes: 12585728518077
      rx_queue_1_packets: 17194262916
      rx_queue_1_bytes: 12518731583464
      rx_queue_2_packets: 17342312348
      rx_queue_2_bytes: 12734959063176
      rx_queue_3_packets: 17367632051
      rx_queue_3_bytes: 12656219984521
      rx_queue_4_packets: 17150307164
      rx_queue_4_bytes: 12408526754019
      rx_queue_5_packets: 17206721842
      rx_queue_5_bytes: 12470666039893
      rx_queue_6_packets: 17202210572
      rx_queue_6_bytes: 12431429298950
      rx_queue_7_packets: 17295822822
      rx_queue_7_bytes: 12573299488239

and here look at multiq queue number 8:
tc -s -d class show dev eth2
class multiq 1:1 parent 1:
  Sent 6905560675905 bytes 510743840 pkt (dropped 0, overlimits 0 
requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:2 parent 1:
  Sent 280699743990 bytes 330210442 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:3 parent 1:
  Sent 128528666971 bytes 142053106 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:4 parent 1:
  Sent 123086710694 bytes 140454119 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:5 parent 1:
  Sent 121027779083 bytes 146164066 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:6 parent 1:
  Sent 116245520195 bytes 141597610 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:7 parent 1:
  Sent 133310553887 bytes 151141714 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
class multiq 1:8 parent 1:
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0

Is that normal that driver don't use queue number 8 ?

