From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: RE: qlcnic very high TX values, as of 3.13.x
Date: Fri, 11 Jul 2014 12:03:06 +0000 (UTC)
Message-ID: <alpine.LRH.2.11.1407111119290.20203@diagnostix.dwd.de>
References: <alpine.LRH.2.11.1407110911560.20203@diagnostix.dwd.de> <262CB373A6D1F14F9B81E82F74F77D5A46FF13B8@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ofcsgdbm.dwd.de ([141.38.3.245]:48667 "EHLO ofcsgdbm.dwd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbaGKMDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 08:03:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by ofcsgdn4.dwd.de (Postfix) with ESMTP id BBFC449F7C
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 12:03:06 +0000 (UTC)
Received: from ofcsgdn4.dwd.de ([127.0.0.1])
	by localhost (ofcsgdn4.csg.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id vQTZLEZ3W-8P for <netdev@vger.kernel.org>;
	Fri, 11 Jul 2014 12:03:06 +0000 (UTC)
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A46FF13B8@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shahed,

first thank you for the very quick reply!

On Fri, 11 Jul 2014, Shahed Shaikh wrote:

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Holger Kiehl
>> Sent: Friday, July 11, 2014 2:43 PM
>> To: netdev
>> Subject: qlcnic very high TX values, as of 3.13.x
>>
>> Hello,
>
> Hi Holger,
>
>>
>> upgrading from 3.10.x to the next stable series 3.14.x I noticed that ifconfig
>> reports very high TX values. Taking the qlcnic source from
>> 3.15.5 and compile it under 3.14.12, the problem remains. Going backwards
>> always just copying the qlcnic source from the older kernels to the 3.14.12
>> tree, I noticed that the 3.12.x kernel was the last version that does not
>> generate those high TX values. So the problem started with the qlcnic driver
>> in 3.13.x. However, comparing 3.13.x and 3.14.x the numbers go higher in
>> 3.14.x much quicker. In 3.14.x I get TX values in Terabytes very quickly after
>> boot. I once even got Petabyte values!
>
> Can you please provide qlcnic driver version used in 3.12.x?
> Please use "ethtool -i ethX" to get this info.
>
    driver: qlcnic
    version: 5.3.50
    firmware-version: 4.14.26
    bus-info: 0000:1a:00.0
    supports-statistics: yes
    supports-test: yes
    supports-eeprom-access: yes
    supports-register-dump: yes
    supports-priv-flags: no


> Also, can you please provide driver statistics o/p with both kernels (3.12.x and 3.14.x).
> Please use "ethtool -S ethX" command to collect driver statistics.
> This would tell us if QLogic adapter indeed sent huge traffic or it's a bug in Tx statistics as part of ifconfig command.
>
Here the statistics for 3.12.x driver (several hours active):

    NIC statistics:
         tx_ring_0 xmit_on: 0
         tx_ring_0 xmit_off: 0
         tx_ring_0 xmit_called: 1442286
         tx_ring_0 xmit_finished: 1442286
         tx_ring_1 xmit_on: 0
         tx_ring_1 xmit_off: 0
         tx_ring_1 xmit_called: 3723601
         tx_ring_1 xmit_finished: 3723601
         tx_ring_2 xmit_on: 0
         tx_ring_2 xmit_off: 0
         tx_ring_2 xmit_called: 1834668
         tx_ring_2 xmit_finished: 1834668
         tx_ring_3 xmit_on: 0
         tx_ring_3 xmit_off: 0
         tx_ring_3 xmit_called: 1912342
         tx_ring_3 xmit_finished: 1912342
         xmit_called: 8908221
         xmit_finished: 8912897
         rx_dropped: 0
         tx_dropped: 0
         csummed: 30901897
         rx_pkts: 28205500
         lro_pkts: 2730164
         rx_bytes: 7086023644
         tx_bytes: 100481331016
         lrobytes: 17026517020
         lso_frames: 5596745
         xmit_on: 0
         xmit_off: 0
         skb_alloc_failure: 0
         null rxbuf: 0
         rx dma map error: 0
         tx dma map error: 0
         mac_filter_limit_overrun: 0
         spurious intr: 0
         mac_tx_frames: 71784854
         mac_tx_bytes: 104815920774
         mac_tx_mcast_pkts: 0
         mac_tx_bcast_pkts: 0
         mac_tx_pause_cnt: 0
         mac_tx_ctrl_pkt: 0
         mac_tx_lt_64b_pkts: 0
         mac_tx_lt_127b_pkts: 0
         mac_tx_lt_255b_pkts: 0
         mac_tx_lt_511b_pkts: 0
         mac_tx_lt_1023b_pkts: 0
         mac_tx_lt_1518b_pkts: 0
         mac_tx_gt_1518b_pkts: 0
         mac_rx_frames: 40264667
         mac_rx_bytes: 24815536295
         mac_rx_mcast_pkts: 115503
         mac_rx_bcast_pkts: 0
         mac_rx_pause_cnt: 0
         mac_rx_ctrl_pkt: 0

And here the statistics for 3.14.x driver (several minutes active):

    NIC statistics:
         tx_queue_0 xmit_on: 0
         tx_queue_0 xmit_off: 0
         tx_queue_0 xmit_called: 70828
         tx_queue_0 xmit_finished: 70828
         tx_queue_0 tx_bytes: 9745074
         tx_queue_1 xmit_on: 0
         tx_queue_1 xmit_off: 0
         tx_queue_1 xmit_called: 10177
         tx_queue_1 xmit_finished: 10177
         tx_queue_1 tx_bytes: 3113256
         tx_queue_2 xmit_on: 0
         tx_queue_2 xmit_off: 0
         tx_queue_2 xmit_called: 144260
         tx_queue_2 xmit_finished: 144260
         tx_queue_2 tx_bytes: 20228745
         tx_queue_3 xmit_on: 0
         tx_queue_3 xmit_off: 0
         tx_queue_3 xmit_called: 7772
         tx_queue_3 xmit_finished: 7772
         tx_queue_3 tx_bytes: 1633447
         xmit_on: 0
         xmit_off: 0
         xmit_called: 232147086
         xmit_finished: 232145654
         tx dma map error: 0
         tx_bytes: 34305725918
         tx_dropped: 0
         rx dma map error: 0
         rx_pkts: 811052
         rx_bytes: 1120370109
         rx_dropped: 0
         null rxbuf: 0
         csummed: 809679
         lro_pkts: 0
         lrobytes: 0
         lso_frames: 743
         skb_alloc_failure: 0
         mac_filter_limit_overrun: 0
         spurious intr: 0
         mac_tx_frames: 235650
         mac_tx_bytes: 35821610
         mac_tx_mcast_pkts: 0
         mac_tx_bcast_pkts: 0
         mac_tx_pause_cnt: 0
         mac_tx_ctrl_pkt: 0
         mac_tx_lt_64b_pkts: 0
         mac_tx_lt_127b_pkts: 0
         mac_tx_lt_255b_pkts: 0
         mac_tx_lt_511b_pkts: 0
         mac_tx_lt_1023b_pkts: 0
         mac_tx_lt_1518b_pkts: 0
         mac_tx_gt_1518b_pkts: 0
         mac_rx_frames: 828024
         mac_rx_bytes: 1122192441
         mac_rx_mcast_pkts: 16903
         mac_rx_bcast_pkts: 0
         mac_rx_pause_cnt: 0
         mac_rx_ctrl_pkt: 0
         mac_rx_lt_64b_pkts: 0
         mac_rx_lt_127b_pkts: 0
         mac_rx_lt_255b_pkts: 0
         mac_rx_lt_511b_pkts: 0
         mac_rx_lt_1023b_pkts: 0
         mac_rx_lt_1518b_pkts: 0
         mac_rx_gt_1518b_pkts: 0
         mac_rx_length_error: 0
         mac_rx_length_small: 0
         mac_rx_length_large: 0
         mac_rx_jabber: 0
         mac_rx_dropped: 2
         mac_crc_error: 0
         mac_align_error: 0
         eswitch_frames: 0
         eswitch_bytes: 0
         eswitch_multicast_frames: 0
         eswitch_broadcast_frames: 0
         eswitch_unicast_frames: 0
         eswitch_error_free_frames: 0
         eswitch_error_free_bytes: 0

Here just for completnes the output of ethtool -i with 3.14 driver:

    driver: qlcnic
    version: 5.3.55
    firmware-version: 4.14.26
    bus-info: 0000:1a:00.0
    supports-statistics: yes
    supports-test: yes
    supports-eeprom-access: yes
    supports-register-dump: yes
    supports-priv-flags: no

I am quite shure that there is no traffic going out, since I can see
this with my distribution software running there (ifconfig reports
30 GiB, my software under 1 MB).

Thank you for looking into this!

Regards,
Holger

> Thanks,
> Shahed
>>
>> Hardware is the following:
>>
>>       HP ProLiant DL380 G7
>>       2 x Intel Xeon X5690 (24 cores with hypertreading)
>>       106 GByte Ram
>>       1 x NC523SFP 10Gb 2-port Server Adapter Board Chip rev 0x54 (qlcnic)
>>       1 x Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection
>>       (ixgbe)
>>
>> The qlcnic and ixgbe cards are bonded together in fault-tolerance
>> (active-backup) mode. And even when I switch to the Intel card, after I get
>> crazy TX values on qlcnic card, the TX vaules on this card still go up at a very
>> quick rate. This only stops when I reset the card (reload the module). Also,
>> there is no differnce if I compile the driver in or use it as module. There are
>> no strange messages in /var/log/messages or dmesg. Here the output with
>> the 3.13.x driver in
>> 3.14.12 when system boots:
>>
>>      [   18.229195] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver
>>      v5.3.52
>>      [   18.229415] qlcnic 0000:1a:00.0: 2048KB memory map
>>      [   18.854134] qlcnic 0000:1a:00.0: Default minidump capture mask 0x1f
>>      [   19.602491] qlcnic 0000:1a:00.0: FW dump enabled
>>      [   19.631257] qlcnic 0000:1a:00.0: Supports FW dump capability
>>      [   19.667072] qlcnic 0000:1a:00.0: Driver v5.3.52, firmware v4.14.26
>>      [   19.704279] qlcnic 0000:1a:00.0: Set 4 Tx rings
>>      [   19.733001] qlcnic 0000:1a:00.0: Set 4 SDS rings
>>      [   19.898808] qlcnic: 2c:27:d7:50:04:48: NC523SFP 10Gb 2-port Server
>>      Adapter Board Chip rev 0x54
>>      [   19.949325] qlcnic 0000:1a:00.0: irq 129 for MSI/MSI-X
>>      [   19.949329] qlcnic 0000:1a:00.0: irq 130 for MSI/MSI-X
>>      [   19.949333] qlcnic 0000:1a:00.0: irq 131 for MSI/MSI-X
>>      [   19.949336] qlcnic 0000:1a:00.0: irq 132 for MSI/MSI-X
>>      [   19.949340] qlcnic 0000:1a:00.0: irq 133 for MSI/MSI-X
>>      [   19.949343] qlcnic 0000:1a:00.0: irq 134 for MSI/MSI-X
>>      [   19.949347] qlcnic 0000:1a:00.0: irq 135 for MSI/MSI-X
>>      [   19.949350] qlcnic 0000:1a:00.0: irq 136 for MSI/MSI-X
>>      [   19.949369] qlcnic 0000:1a:00.0: using msi-x interrupts
>>      [   19.982782] qlcnic 0000:1a:00.0: Set 4 Tx queues
>>      [   20.055099] qlcnic 0000:1a:00.0: eth2: XGbE port initialized
>>      [   20.090408] qlcnic 0000:1a:00.1: 2048KB memory map
>>      [   20.179836] qlcnic 0000:1a:00.1: Default minidump capture mask 0x1f
>>      [   20.217848] qlcnic 0000:1a:00.1: FW dump enabled
>>      [   20.246979] qlcnic 0000:1a:00.1: Supports FW dump capability
>>      [   20.282318] qlcnic 0000:1a:00.1: Driver v5.3.52, firmware v4.14.26
>>      [   20.320238] qlcnic 0000:1a:00.1: Set 4 Tx rings
>>      [   20.350038] qlcnic 0000:1a:00.1: Set 4 SDS rings
>>      [   20.429714] qlcnic 0000:1a:00.1: irq 137 for MSI/MSI-X
>>      [   20.429718] qlcnic 0000:1a:00.1: irq 138 for MSI/MSI-X
>>      [   20.429722] qlcnic 0000:1a:00.1: irq 139 for MSI/MSI-X
>>      [   20.429726] qlcnic 0000:1a:00.1: irq 140 for MSI/MSI-X
>>      [   20.429729] qlcnic 0000:1a:00.1: irq 141 for MSI/MSI-X
>>      [   20.429732] qlcnic 0000:1a:00.1: irq 142 for MSI/MSI-X
>>      [   20.429736] qlcnic 0000:1a:00.1: irq 143 for MSI/MSI-X
>>      [   20.429739] qlcnic 0000:1a:00.1: irq 144 for MSI/MSI-X
>>      [   20.429757] qlcnic 0000:1a:00.1: using msi-x interrupts
>>      [   20.458895] qlcnic 0000:1a:00.1: Set 4 Tx queues
>>      [   20.486907] qlcnic 0000:1a:00.1: eth3: XGbE port initialized
>>
>> My kernel config can be downloaded here:
>>
>>     ftp://ftp.dwd.de/pub/afd/test/.config
>>
>> Please, just ask if I need to provide more details and please CC me, since I am
>> not on the list.
>>
>> Thanks,
>> Holger
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
>> of a message to majordomo@vger.kernel.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
>
