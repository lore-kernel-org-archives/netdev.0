From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: Problems with ixgbe driver
Date: Mon, 24 Jun 2013 14:38:33 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FDCACB9@FMSMSX105.amr.corp.intel.com>
References: <alpine.LRH.2.02.1306141031490.22892@praktifix.dwd.de>
 <87618083B2453E4A8714035B62D679924FDC4748@FMSMSX105.amr.corp.intel.com>
 <alpine.LRH.2.02.1306170848230.28669@praktifix.dwd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Holger Kiehl <Holger.Kiehl@dwd.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.02.1306170848230.28669@praktifix.dwd.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Holger Kiehl [mailto:Holger.Kiehl@dwd.de]
>Sent: Monday, June 17, 2013 2:12 AM
>To: Tantilov, Emil S
>Cc: e1000-devel@lists.sf.net; linux-kernel; netdev@vger.kernel.org
>Subject: RE: Problems with ixgbe driver
>
>Hello,
>
>first, thank you for the quick help!
>
>On Fri, 14 Jun 2013, Tantilov, Emil S wrote:
>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On
>>> Behalf Of Holger Kiehl
>>> Sent: Friday, June 14, 2013 4:50 AM
>>> To: e1000-devel@lists.sf.net
>>> Cc: linux-kernel; netdev@vger.kernel.org
>>> Subject: Problems with ixgbe driver
>>>
>>> Hello,
>>>
>>> I have dual port 10Gb Intel network card on a 2 socket (Xeon X5690) with
>>> a total of 12 cores. Hyperthreading is enabled so there are 24 cores.
>>> The problem I have is that when other systems send large amount of data
>>> the network with the intel ixgbe driver gets very slow. Ping times go up
>>> from 0.2ms to appr. 60ms. Some FTP connections stall for more then 2
>>> minutes. What is strange is that heatbeat is configured on the system
>>> with a serial connection to another node and kernel always reports
>>
>> If the network slows down so much there should be some indication in
>dmesg. Like Tx hangs perhaps.
>> Can you provide the output of dmesg and ethtool -S from the offending
>interface after the issue occurs?
>>
>No, there is absolute no indication in dmesg or /var/log/messages. But here
>the ethtool output when ping times go up:
>
>    root@helena:~# ethtool -S eth6
>    NIC statistics:
>         rx_packets: 4410779
>         tx_packets: 8902514
>         rx_bytes: 2014041824
>         tx_bytes: 13199913202
>         rx_errors: 0
>         tx_errors: 0
>         rx_dropped: 0
>         tx_dropped: 0
>         multicast: 4245
>         collisions: 0
>         rx_over_errors: 0
>         rx_crc_errors: 0
>         rx_frame_errors: 0
>         rx_fifo_errors: 0
>         rx_missed_errors: 28143
>         tx_aborted_errors: 0
>         tx_carrier_errors: 0
>         tx_fifo_errors: 0
>         tx_heartbeat_errors: 0
>         rx_pkts_nic: 2401276937
>         tx_pkts_nic: 3868619482
>         rx_bytes_nic: 868282794731
>         tx_bytes_nic: 5743382228649
>         lsc_int: 4
>         tx_busy: 0
>         non_eop_descs: 743957
>         broadcast: 1745556
>         rx_no_buffer_count: 0
>         tx_timeout_count: 0
>         tx_restart_queue: 425
>         rx_long_length_errors: 0
>         rx_short_length_errors: 0
>         tx_flow_control_xon: 171
>         rx_flow_control_xon: 0
>         tx_flow_control_xoff: 277
>         rx_flow_control_xoff: 0
>         rx_csum_offload_errors: 0
>         alloc_rx_page_failed: 0
>         alloc_rx_buff_failed: 0
>         lro_aggregated: 0
>         lro_flushed: 0
>         rx_no_dma_resources: 0
>         hw_rsc_aggregated: 1153374
>         hw_rsc_flushed: 129169
>         fdir_match: 2424508153
>         fdir_miss: 1706029
>         fdir_overflow: 33
>         os2bmc_rx_by_bmc: 0
>         os2bmc_tx_by_bmc: 0
>         os2bmc_tx_by_host: 0
>         os2bmc_rx_by_host: 0
>         tx_queue_0_packets: 470182
>         tx_queue_0_bytes: 690123121
>         tx_queue_1_packets: 797784
>         tx_queue_1_bytes: 1203968369
>         tx_queue_2_packets: 648692
>         tx_queue_2_bytes: 950171718
>         tx_queue_3_packets: 647434
>         tx_queue_3_bytes: 948647518
>         tx_queue_4_packets: 263216
>         tx_queue_4_bytes: 394806409
>         tx_queue_5_packets: 426786
>         tx_queue_5_bytes: 629387628
>         tx_queue_6_packets: 253708
>         tx_queue_6_bytes: 371774276
>         tx_queue_7_packets: 544634
>         tx_queue_7_bytes: 812223169
>         tx_queue_8_packets: 279056
>         tx_queue_8_bytes: 407792510
>         tx_queue_9_packets: 735792
>         tx_queue_9_bytes: 1092693961
>         tx_queue_10_packets: 393576
>         tx_queue_10_bytes: 583283986
>         tx_queue_11_packets: 712565
>         tx_queue_11_bytes: 1037740789
>         tx_queue_12_packets: 264445
>         tx_queue_12_bytes: 386010613
>         tx_queue_13_packets: 246828
>         tx_queue_13_bytes: 370387352
>         tx_queue_14_packets: 191789
>         tx_queue_14_bytes: 281160607
>         tx_queue_15_packets: 384581
>         tx_queue_15_bytes: 579890782
>         tx_queue_16_packets: 175119
>         tx_queue_16_bytes: 261312970
>         tx_queue_17_packets: 151219
>         tx_queue_17_bytes: 220259675
>         tx_queue_18_packets: 467746
>         tx_queue_18_bytes: 707472612
>         tx_queue_19_packets: 30642
>         tx_queue_19_bytes: 44896997
>         tx_queue_20_packets: 157957
>         tx_queue_20_bytes: 238772784
>         tx_queue_21_packets: 287819
>         tx_queue_21_bytes: 434965075
>         tx_queue_22_packets: 269298
>         tx_queue_22_bytes: 407637986
>         tx_queue_23_packets: 102344
>         tx_queue_23_bytes: 145542751
>         rx_queue_0_packets: 219438
>         rx_queue_0_bytes: 273936020
>         rx_queue_1_packets: 398269
>         rx_queue_1_bytes: 52080243
>         rx_queue_2_packets: 285870
>         rx_queue_2_bytes: 102299543
>         rx_queue_3_packets: 347238
>         rx_queue_3_bytes: 145830086
>         rx_queue_4_packets: 118448
>         rx_queue_4_bytes: 17515218
>         rx_queue_5_packets: 228029
>         rx_queue_5_bytes: 114142681
>         rx_queue_6_packets: 94285
>         rx_queue_6_bytes: 107618165
>         rx_queue_7_packets: 289615
>         rx_queue_7_bytes: 168428647
>         rx_queue_8_packets: 109288
>         rx_queue_8_bytes: 35178080
>         rx_queue_9_packets: 393061
>         rx_queue_9_bytes: 377122152
>         rx_queue_10_packets: 155004
>         rx_queue_10_bytes: 66560302
>         rx_queue_11_packets: 381580
>         rx_queue_11_bytes: 182550920
>         rx_queue_12_packets: 140681
>         rx_queue_12_bytes: 44514373
>         rx_queue_13_packets: 127091
>         rx_queue_13_bytes: 18524907
>         rx_queue_14_packets: 92548
>         rx_queue_14_bytes: 34725166
>         rx_queue_15_packets: 199612
>         rx_queue_15_bytes: 66689821
>         rx_queue_16_packets: 90018
>         rx_queue_16_bytes: 29206483
>         rx_queue_17_packets: 81277
>         rx_queue_17_bytes: 55206035
>         rx_queue_18_packets: 224446
>         rx_queue_18_bytes: 14869858
>         rx_queue_19_packets: 16975
>         rx_queue_19_bytes: 48400959
>         rx_queue_20_packets: 80806
>         rx_queue_20_bytes: 5398100
>         rx_queue_21_packets: 146815
>         rx_queue_21_bytes: 9796087
>         rx_queue_22_packets: 136018
>         rx_queue_22_bytes: 9023369
>         rx_queue_23_packets: 54781
>         rx_queue_23_bytes: 34724433
>
>This was with the 3.15.1 driver and setting the combinde queue to 24 via
>ethtool, as you suggested below.

Sorry for the late reply.

There are 2 counters that could be related to this:

rx_missed_errors and fdir_overflow. Since you see better results by lowering the number of queues I'm guessing it's most likely due to the Flow Director running out of filters. If you can easily reproduce this - run watch -d -n1 "ethtool -S ethX" and see if you can catch any of these counters incrementing.

You need an account at sourceforge in order to submit a ticket.

Thanks,
Emil
