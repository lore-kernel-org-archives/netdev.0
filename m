From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: Re: Problems with ixgbe driver
Date: Mon, 17 Jun 2013 09:11:45 +0000 (GMT)
Message-ID: <alpine.LRH.2.02.1306170848230.28669@praktifix.dwd.de>
References: <alpine.LRH.2.02.1306141031490.22892@praktifix.dwd.de>
	<87618083B2453E4A8714035B62D679924FDC4748@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87618083B2453E4A8714035B62D679924FDC4748@FMSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello,

first, thank you for the quick help!

On Fri, 14 Jun 2013, Tantilov, Emil S wrote:

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of Holger Kiehl
>> Sent: Friday, June 14, 2013 4:50 AM
>> To: e1000-devel@lists.sf.net
>> Cc: linux-kernel; netdev@vger.kernel.org
>> Subject: Problems with ixgbe driver
>>
>> Hello,
>>
>> I have dual port 10Gb Intel network card on a 2 socket (Xeon X5690) with
>> a total of 12 cores. Hyperthreading is enabled so there are 24 cores.
>> The problem I have is that when other systems send large amount of data
>> the network with the intel ixgbe driver gets very slow. Ping times go up
>> from 0.2ms to appr. 60ms. Some FTP connections stall for more then 2
>> minutes. What is strange is that heatbeat is configured on the system
>> with a serial connection to another node and kernel always reports
>
> If the network slows down so much there should be some indication in dmesg. Like Tx hangs perhaps.
> Can you provide the output of dmesg and ethtool -S from the offending interface after the issue occurs?
>
No, there is absolute no indication in dmesg or /var/log/messages. But here
the ethtool output when ping times go up:

    root@helena:~# ethtool -S eth6
    NIC statistics:
         rx_packets: 4410779
         tx_packets: 8902514
         rx_bytes: 2014041824
         tx_bytes: 13199913202
         rx_errors: 0
         tx_errors: 0
         rx_dropped: 0
         tx_dropped: 0
         multicast: 4245
         collisions: 0
         rx_over_errors: 0
         rx_crc_errors: 0
         rx_frame_errors: 0
         rx_fifo_errors: 0
         rx_missed_errors: 28143
         tx_aborted_errors: 0
         tx_carrier_errors: 0
         tx_fifo_errors: 0
         tx_heartbeat_errors: 0
         rx_pkts_nic: 2401276937
         tx_pkts_nic: 3868619482
         rx_bytes_nic: 868282794731
         tx_bytes_nic: 5743382228649
         lsc_int: 4
         tx_busy: 0
         non_eop_descs: 743957
         broadcast: 1745556
         rx_no_buffer_count: 0
         tx_timeout_count: 0
         tx_restart_queue: 425
         rx_long_length_errors: 0
         rx_short_length_errors: 0
         tx_flow_control_xon: 171
         rx_flow_control_xon: 0
         tx_flow_control_xoff: 277
         rx_flow_control_xoff: 0
         rx_csum_offload_errors: 0
         alloc_rx_page_failed: 0
         alloc_rx_buff_failed: 0
         lro_aggregated: 0
         lro_flushed: 0
         rx_no_dma_resources: 0
         hw_rsc_aggregated: 1153374
         hw_rsc_flushed: 129169
         fdir_match: 2424508153
         fdir_miss: 1706029
         fdir_overflow: 33
         os2bmc_rx_by_bmc: 0
         os2bmc_tx_by_bmc: 0
         os2bmc_tx_by_host: 0
         os2bmc_rx_by_host: 0
         tx_queue_0_packets: 470182
         tx_queue_0_bytes: 690123121
         tx_queue_1_packets: 797784
         tx_queue_1_bytes: 1203968369
         tx_queue_2_packets: 648692
         tx_queue_2_bytes: 950171718
         tx_queue_3_packets: 647434
         tx_queue_3_bytes: 948647518
         tx_queue_4_packets: 263216
         tx_queue_4_bytes: 394806409
         tx_queue_5_packets: 426786
         tx_queue_5_bytes: 629387628
         tx_queue_6_packets: 253708
         tx_queue_6_bytes: 371774276
         tx_queue_7_packets: 544634
         tx_queue_7_bytes: 812223169
         tx_queue_8_packets: 279056
         tx_queue_8_bytes: 407792510
         tx_queue_9_packets: 735792
         tx_queue_9_bytes: 1092693961
         tx_queue_10_packets: 393576
         tx_queue_10_bytes: 583283986
         tx_queue_11_packets: 712565
         tx_queue_11_bytes: 1037740789
         tx_queue_12_packets: 264445
         tx_queue_12_bytes: 386010613
         tx_queue_13_packets: 246828
         tx_queue_13_bytes: 370387352
         tx_queue_14_packets: 191789
         tx_queue_14_bytes: 281160607
         tx_queue_15_packets: 384581
         tx_queue_15_bytes: 579890782
         tx_queue_16_packets: 175119
         tx_queue_16_bytes: 261312970
         tx_queue_17_packets: 151219
         tx_queue_17_bytes: 220259675
         tx_queue_18_packets: 467746
         tx_queue_18_bytes: 707472612
         tx_queue_19_packets: 30642
         tx_queue_19_bytes: 44896997
         tx_queue_20_packets: 157957
         tx_queue_20_bytes: 238772784
         tx_queue_21_packets: 287819
         tx_queue_21_bytes: 434965075
         tx_queue_22_packets: 269298
         tx_queue_22_bytes: 407637986
         tx_queue_23_packets: 102344
         tx_queue_23_bytes: 145542751
         rx_queue_0_packets: 219438
         rx_queue_0_bytes: 273936020
         rx_queue_1_packets: 398269
         rx_queue_1_bytes: 52080243
         rx_queue_2_packets: 285870
         rx_queue_2_bytes: 102299543
         rx_queue_3_packets: 347238
         rx_queue_3_bytes: 145830086
         rx_queue_4_packets: 118448
         rx_queue_4_bytes: 17515218
         rx_queue_5_packets: 228029
         rx_queue_5_bytes: 114142681
         rx_queue_6_packets: 94285
         rx_queue_6_bytes: 107618165
         rx_queue_7_packets: 289615
         rx_queue_7_bytes: 168428647
         rx_queue_8_packets: 109288
         rx_queue_8_bytes: 35178080
         rx_queue_9_packets: 393061
         rx_queue_9_bytes: 377122152
         rx_queue_10_packets: 155004
         rx_queue_10_bytes: 66560302
         rx_queue_11_packets: 381580
         rx_queue_11_bytes: 182550920
         rx_queue_12_packets: 140681
         rx_queue_12_bytes: 44514373
         rx_queue_13_packets: 127091
         rx_queue_13_bytes: 18524907
         rx_queue_14_packets: 92548
         rx_queue_14_bytes: 34725166
         rx_queue_15_packets: 199612
         rx_queue_15_bytes: 66689821
         rx_queue_16_packets: 90018
         rx_queue_16_bytes: 29206483
         rx_queue_17_packets: 81277
         rx_queue_17_bytes: 55206035
         rx_queue_18_packets: 224446
         rx_queue_18_bytes: 14869858
         rx_queue_19_packets: 16975
         rx_queue_19_bytes: 48400959
         rx_queue_20_packets: 80806
         rx_queue_20_bytes: 5398100
         rx_queue_21_packets: 146815
         rx_queue_21_bytes: 9796087
         rx_queue_22_packets: 136018
         rx_queue_22_bytes: 9023369
         rx_queue_23_packets: 54781
         rx_queue_23_bytes: 34724433

This was with the 3.15.1 driver and setting the combinde queue to 24 via
ethtool, as you suggested below.

>>
>>     ttyS0: 4 input overrun(s)
>>
>> when lot of data is send and the ping time goes up.
>>
>> On the network there are three vlan's configured. The network is bonded
>> (active-backup) together with another HP NC523SFP 10Gb 2-port Server
>> Adapter. When I switch the network to this card the problem goes away.
>> Also the ttyS0 input overruns disappear. Note also both network cards
>> are connected to the same switch.
>>
>> The system uses Scientific Linux 6.4 with kernel.org kernel. I noticed
>> this behavior with kernel 3.9.5 and 3.9.6-rc1. Before I did not notice
>> it because traffic always went over the HP NC523SFP qlcnic card.
>>
>> In search for a solution to the problem I found a newer ixgbe driver
>> 3.15.1 (3.9.6-rc1. has 3.11.33-k) and tried that. But it has the same
>> problem. However when I load the module as follows:
>>
>>     modprobe ixgbe RSS=8,8
>>
>> the problem goes away. The kernel.org ixgbe driver does not offer this
>> option. Why? It seems that both drivers have problems on systems with
>
> If you are using newer kernel and ethtool version you can use `ethtool -L ethX combined Y` to control the number of queues per interface.
>
Okay, thank you! I did not know this.

>> 24 cpu's. But I cannot believe that I am the only one who noticed this,
>> since ixgbe is widely used.
>
> We run traffic with multiple queues all the time and I don't think what you are reporting is a generic issue. Most likely it's something related to your setup/system.
>
Yes, I think so too. But what could it be? Please, just ask what other
information I could provide. As I already mentioned earlier the ixgbe card
is bonded with a qlogic nic and I have two (not three) vlan configured over
over this bond. Maybe the following is useful (eth6 is the ixgbe driver):

    root@helena:~# ethtool -k eth6
    Features for eth6:
    rx-checksumming: on
    tx-checksumming: on
            tx-checksum-ipv4: on
            tx-checksum-ip-generic: off [fixed]
            tx-checksum-ipv6: on
            tx-checksum-fcoe-crc: off [fixed]
            tx-checksum-sctp: on
    scatter-gather: on
            tx-scatter-gather: on
            tx-scatter-gather-fraglist: off [fixed]
    tcp-segmentation-offload: on
            tx-tcp-segmentation: on
            tx-tcp-ecn-segmentation: off [fixed]
            tx-tcp6-segmentation: on
    udp-fragmentation-offload: off [fixed]
    generic-segmentation-offload: on
    generic-receive-offload: on
    large-receive-offload: on
    rx-vlan-offload: on
    tx-vlan-offload: on
    ntuple-filters: off
    receive-hashing: on
    highdma: on [fixed]
    rx-vlan-filter: on [fixed]
    vlan-challenged: off [fixed]
    tx-lockless: off [fixed]
    netns-local: off [fixed]
    tx-gso-robust: off [fixed]
    tx-fcoe-segmentation: off [fixed]
    tx-gre-segmentation: off [fixed]
    fcoe-mtu: off [fixed]
    tx-nocache-copy: on
    loopback: off [fixed]
    rx-fcs: off [fixed]
    rx-all: off [fixed]

>>
>> It would really be nice if one could set the RSS=8,8 option for kernel.org
>> ixgbe driver too. Or if someone could tell me where I can force the driver
>> to Receive Side Scaling to 8 even if it means editing the source code.
>>
>> Below I have added some additional information. Please CC me since I
>> am not subscribed to any of these lists. And please do not hesitate
>> to ask if more information is needed.
>
> I would suggest that you open up a bug at e1000.sf.net - describe your configuration and attach the relevant info (dmesg, ethtool -S, lspci etc). This would make it easier for us to follow.
>
Sorry, but I could not find out how I can open a new bug. I could just view
existing bugs. Please give me a hint what I need to do.

Thanks,
Holger

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
