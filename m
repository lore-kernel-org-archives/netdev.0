From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Problem with ixgbe and TX locked on one cpu
Date: Fri, 14 Oct 2011 21:18:54 +0200
Message-ID: <4E988B1E.5000606@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070205070608090702010701"
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.iq.pl ([86.111.242.20]:53178 "EHLO smtp4.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932153Ab1JNTZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 15:25:42 -0400
Received: from unknown (HELO [192.168.1.200]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 14 Oct 2011 19:19:00 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070205070608090702010701
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Hello

I have weird problem with ixgbe and irq affinity / rx-tx queue assignment

Statistics for my ethernet - ixgbe driver:
ethtool -S eth4
NIC statistics:
      rx_packets: 5815535848808
      tx_packets: 5811202378421
      rx_bytes: 4791001750842200
      tx_bytes: 4781190419358301
      rx_pkts_nic: 5815535848827
      tx_pkts_nic: 5811202378510
      rx_bytes_nic: 4837563124411799
      tx_bytes_nic: 4829987507084013
      lsc_int: 8
      tx_busy: 0
      non_eop_descs: 0
      rx_errors: 0
      tx_errors: 0
      rx_dropped: 0
      tx_dropped: 0
      multicast: 92494273
      broadcast: 268718206
      rx_no_buffer_count: 28829
      collisions: 0
      rx_over_errors: 0
      rx_crc_errors: 0
      rx_frame_errors: 0
      hw_rsc_aggregated: 0
      hw_rsc_flushed: 0
      fdir_match: 0
      fdir_miss: 0
      rx_fifo_errors: 0
      rx_missed_errors: 307051074
      tx_aborted_errors: 0
      tx_carrier_errors: 0
      tx_fifo_errors: 0
      tx_heartbeat_errors: 0
      tx_timeout_count: 0
      tx_restart_queue: 15926219
      rx_long_length_errors: 298
      rx_short_length_errors: 0
      tx_flow_control_xon: 0
      rx_flow_control_xon: 0
      tx_flow_control_xoff: 0
      rx_flow_control_xoff: 0
      rx_csum_offload_errors: 54173917
      alloc_rx_page_failed: 0
      alloc_rx_buff_failed: 0
      rx_no_dma_resources: 0
      tx_queue_0_packets: 68694825
      tx_queue_0_bytes: 9443750332
      tx_queue_1_packets: 8410961
      tx_queue_1_bytes: 2527763233
      tx_queue_2_packets: 14411252
      tx_queue_2_bytes: 1317132394
      tx_queue_3_packets: 15013508147
      tx_queue_3_bytes: 17364767277348
      tx_queue_4_packets: 62779891
      tx_queue_4_bytes: 63476596221
      tx_queue_5_packets: 11176001
      tx_queue_5_bytes: 2763600253
      tx_queue_6_packets: 4416357
      tx_queue_6_bytes: 611874984
      tx_queue_7_packets: 8933405
      tx_queue_7_bytes: 1837198524
      tx_queue_8_packets: 13292669
      tx_queue_8_bytes: 3241333510
      tx_queue_9_packets: 10747236
      tx_queue_9_bytes: 1805109931
      tx_queue_10_packets: 5795935258380
      tx_queue_10_bytes: 4763725304722245
      tx_queue_11_packets: 12073934
      tx_queue_11_bytes: 2982743045
      tx_queue_12_packets: 10523764
      tx_queue_12_bytes: 2637451199
      tx_queue_13_packets: 12480552
      tx_queue_13_bytes: 2434827407
      tx_queue_14_packets: 7401777
      tx_queue_14_bytes: 2413618099
      tx_queue_15_packets: 8269270
      tx_queue_15_bytes: 2854359576
      rx_queue_0_packets: 361373769507
      rx_queue_0_bytes: 298565751248279
      rx_queue_1_packets: 369901571908
      rx_queue_1_bytes: 303414679798160
      rx_queue_2_packets: 362508961738
      rx_queue_2_bytes: 299852439447157
      rx_queue_3_packets: 363449272013
      rx_queue_3_bytes: 299738390792515
      rx_queue_4_packets: 361876234461
      rx_queue_4_bytes: 297483366939732
      rx_queue_5_packets: 361402926316
      rx_queue_5_bytes: 297633876486533
      rx_queue_6_packets: 362261522767
      rx_queue_6_bytes: 298026696344647
      rx_queue_7_packets: 361248593301
      rx_queue_7_bytes: 296756459279986
      rx_queue_8_packets: 361654143416
      rx_queue_8_bytes: 298272433659520
      rx_queue_9_packets: 362781764710
      rx_queue_9_bytes: 298804803191595
      rx_queue_10_packets: 361386593064
      rx_queue_10_bytes: 297434987797644
      rx_queue_11_packets: 369886597895
      rx_queue_11_bytes: 302353350171712
      rx_queue_12_packets: 361582732276
      rx_queue_12_bytes: 298670408005971
      rx_queue_13_packets: 365248093536
      rx_queue_13_bytes: 302573023878287
      rx_queue_14_packets: 366571142073
      rx_queue_14_bytes: 302396739276514
      rx_queue_15_packets: 362401929830
      rx_queue_15_bytes: 299024344526029

The problem is with queue 10
      tx_queue_10_packets: 5795935258380
      tx_queue_10_bytes: 4763725304722245

as you can see most of the queue processing is used in queue 10
Average difference is 1,854271229903958e-6  - compared to other queues

and the problem is that almost all TX packet processing is on one CPU
cat /proc/interrupts - in attached file

Is this driver or kernel problem ?

Kernel is: 2.6.38.2

ixgbe driver is:
ethtool -i eth4
driver: ixgbe
version: 3.2.9-k2
firmware-version: 1.12-2
bus-info: 0000:04:00.0


Thanks
Pawel


-- 


--------------070205070608090702010701
Content-Type: text/plain;
 name="interrupts.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="interrupts.txt"

cat /proc/interrupts  | grep eth4
 135: 3109261876    4289060          0          0          0          0          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-0
 136: 2738300312 2654348120    4055848          0          0          0          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-1
 137:         43 2636245312 3776381478    4281702          0          0          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-2
 138:        340 2156086460    3340495 3269054231    4487452          0          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-3
 139:         38          0 2738519426          0 1088719123    4176363          0          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-4
 140:         39          0 2632858749    3512903          0 2307156010    4310322          0          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-5
 141:         41          0          0 2655130571          0          0 2492897896    4249569          0          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-6
 142:        173          0          0 2625727263          0          0          0 2509835335    8038276          0          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-7
 143:         44          0          0          0    2115559          0          0          0 3275187626    5066092          0          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-8
 144:         51          0          0          0          0          0          0          0 2668196538 1238317991    4373599          0          0          0          0          0   PCI-MSI-edge      eth4-TxRx-9
 145:     528852          0          0          0     386077          0          0          0     438158  294605430 1867115075    4806187          0          0          0          0   PCI-MSI-edge      eth4-TxRx-10
 146:         65          0          0          0          0          0          0          0          0 2378013639    3357280 1179087288    4668439          0          0          0   PCI-MSI-edge      eth4-TxRx-11
 147:         83          0          0          0          0          0          0          0          0          0 2447343915          0 1621496283    4718715          0          0   PCI-MSI-edge      eth4-TxRx-12
 148:         64          0          0          0          0          0          0          0          0          0 2719008413    3788138          0 2492359875    4697458          0   PCI-MSI-edge      eth4-TxRx-13
 149:         41          0          0          0          0          0          0          0          0          0          0 2569764726          0          0 3216415633    4546711   PCI-MSI-edge      eth4-TxRx-14
 150:         45          0          0          0          0          0          0          0          0          0          0 2553654902          0          0          0 2587543392   PCI-MSI-edge      eth4-TxRx-15
 151:          5          0          0          0          0          0          0          0          0          0          0          0          0          0          0          3   PCI-MSI-edge      eth4:lsc

--------------070205070608090702010701
Content-Type: text/x-vcard; charset=utf-8;
 name="pstaszewski.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pstaszewski.vcf"

begin:vcard
fn;quoted-printable:Pawe=C5=82 Staszewski
n;quoted-printable:Staszewski;Pawe=C5=82
org:ITCare
adr;quoted-printable;quoted-printable;dom:;;Sikorskiego 22;Libi=C4=85=C5=BC;Ma=C5=82opolskie;32-590
title:IT Manager
tel;work:+48 32 7203681
tel;fax:+48 32 7203682
tel;cell:+48 0 609911040
url:www.itcare.pl
version:2.1
end:vcard


--------------070205070608090702010701--
