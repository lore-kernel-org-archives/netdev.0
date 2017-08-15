From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 15 Aug 2017 12:02:08 +0200
Message-ID: <fee2de62-c781-4ceb-8e97-be2b07eb1ca1@itcare.pl>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
 <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
 <20170814181957.5be27906@redhat.com>
 <1ff1b747-758e-afdd-9376-80ff3bd8a6d5@itcare.pl>
 <20170815112307.2dd366fe@redhat.com>
 <271f731c-080f-8ccb-cd08-f0ec1dfb0c51@itcare.pl>
 <20170815115756.7ef50c23@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:35886 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753358AbdHOKDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 06:03:16 -0400
In-Reply-To: <20170815115756.7ef50c23@redhat.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-08-15 o 11:57, Jesper Dangaard Brouer pisze:
> On Tue, 15 Aug 2017 11:30:43 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>
>> W dniu 2017-08-15 o 11:23, Jesper Dangaard Brouer pisze:
>>> On Tue, 15 Aug 2017 02:38:56 +0200
>>> Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>>>   
>>>> W dniu 2017-08-14 o 18:19, Jesper Dangaard Brouer pisze:
>>>>> On Sun, 13 Aug 2017 18:58:58 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>>>>>      
>>>>>> To show some difference below comparision vlan/no-vlan traffic
>>>>>>
>>>>>> 10Mpps forwarded traffic vith no-vlan vs 6.9Mpps with vlan
>>>>> I'm trying to reproduce in my testlab (with ixgbe).  I do see, a
>>>>> performance reduction of about 10-19% when I forward out a VLAN
>>>>> interface.  This is larger than I expected, but still lower than what
>>>>> you reported 30-40% slowdown.
>>>>>
>>>>> [...]
>>>> Ok mellanox afrrived (MT27700 - mlnx5 driver)
>>>> And to compare melannox with vlans and without: 33% performance
>>>> degradation (less than with ixgbe where i reach ~40% with same settings)
>>>>
>>>> Mellanox without TX traffix on vlan:
>>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>>> 0;16;64;11089305;709715520;8871553;567779392
>>>> 1;16;64;11096292;710162688;11095566;710116224
>>>> 2;16;64;11095770;710129280;11096799;710195136
>>>> 3;16;64;11097199;710220736;11097702;710252928
>>>> 4;16;64;11080984;567081856;11079662;709098368
>>>> 5;16;64;11077696;708972544;11077039;708930496
>>>> 6;16;64;11082991;709311424;8864802;567347328
>>>> 7;16;64;11089596;709734144;8870927;709789184
>>>> 8;16;64;11094043;710018752;11095391;710105024
>>>>
>>>> Mellanox with TX traffic on vlan:
>>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>>> 0;16;64;7369914;471674496;7370281;471697980
>>>> 1;16;64;7368896;471609408;7368043;471554752
>>>> 2;16;64;7367577;471524864;7367759;471536576
>>>> 3;16;64;7368744;377305344;7369391;471641024
>>>> 4;16;64;7366824;471476736;7364330;471237120
>>>> 5;16;64;7368352;471574528;7367239;471503296
>>>> 6;16;64;7367459;471517376;7367806;471539584
>>>> 7;16;64;7367190;471500160;7367988;471551232
>>>> 8;16;64;7368023;471553472;7368076;471556864
>>> I wonder if the drivers page recycler is active/working or not, and if
>>> the situation is different between VLAN vs no-vlan (given
>>> page_frag_free is so high in you perf top).  The Mellanox drivers
>>> fortunately have a stats counter to tell us this explicitly (which the
>>> ixgbe driver doesn't).
>>>
>>> You can use my ethtool_stats.pl script watch these stats:
>>>    https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl
>>> (Hint perl dependency:  dnf install perl-Time-HiRes)
>> For RX NIC:
>> Show adapter(s) (enp175s0f0) statistics (ONLY that changed!)
>> Ethtool(enp175s0f0) stat:     78380071 (     78,380,071) <= rx0_bytes /sec
>> Ethtool(enp175s0f0) stat:       230978 (        230,978) <= rx0_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      1152648 (      1,152,648) <= rx0_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1152648 (      1,152,648) <= rx0_packets /sec
>> Ethtool(enp175s0f0) stat:       921614 (        921,614) <= rx0_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     78956591 (     78,956,591) <= rx1_bytes /sec
>> Ethtool(enp175s0f0) stat:       233343 (        233,343) <= rx1_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      1161126 (      1,161,126) <= rx1_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1161126 (      1,161,126) <= rx1_packets /sec
>> Ethtool(enp175s0f0) stat:       927793 (        927,793) <= rx1_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     79677124 (     79,677,124) <= rx2_bytes /sec
>> Ethtool(enp175s0f0) stat:       233735 (        233,735) <= rx2_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      1171722 (      1,171,722) <= rx2_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1171722 (      1,171,722) <= rx2_packets /sec
>> Ethtool(enp175s0f0) stat:       937989 (        937,989) <= rx2_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     78392893 (     78,392,893) <= rx3_bytes /sec
>> Ethtool(enp175s0f0) stat:       230311 (        230,311) <= rx3_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      1152837 (      1,152,837) <= rx3_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1152837 (      1,152,837) <= rx3_packets /sec
>> Ethtool(enp175s0f0) stat:       922513 (        922,513) <= rx3_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     65165583 (     65,165,583) <= rx4_bytes /sec
>> Ethtool(enp175s0f0) stat:       191969 (        191,969) <= rx4_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:       958317 (        958,317) <= rx4_csum_complete /sec
>> Ethtool(enp175s0f0) stat:       958317 (        958,317) <= rx4_packets /sec
>> Ethtool(enp175s0f0) stat:       766332 (        766,332) <= rx4_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     66920721 (     66,920,721) <= rx5_bytes /sec
>> Ethtool(enp175s0f0) stat:       197150 (        197,150) <= rx5_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:       984128 (        984,128) <= rx5_csum_complete /sec
>> Ethtool(enp175s0f0) stat:       984128 (        984,128) <= rx5_packets /sec
>> Ethtool(enp175s0f0) stat:       786978 (        786,978) <= rx5_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     79076984 (     79,076,984) <= rx6_bytes /sec
>> Ethtool(enp175s0f0) stat:       233735 (        233,735) <= rx6_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      1162897 (      1,162,897) <= rx6_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1162897 (      1,162,897) <= rx6_packets /sec
>> Ethtool(enp175s0f0) stat:       929163 (        929,163) <= rx6_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     78660672 (     78,660,672) <= rx7_bytes /sec
>> Ethtool(enp175s0f0) stat:       230413 (        230,413) <= rx7_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      1156775 (      1,156,775) <= rx7_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1156775 (      1,156,775) <= rx7_packets /sec
>> Ethtool(enp175s0f0) stat:       926376 (        926,376) <= rx7_page_reuse /sec
>> Ethtool(enp175s0f0) stat:     10674565 (     10,674,565) <= rx_65_to_127_bytes_phy /sec
>> Ethtool(enp175s0f0) stat:    605241031 (    605,241,031) <= rx_bytes /sec
>> Ethtool(enp175s0f0) stat:    768585608 (    768,585,608) <= rx_bytes_phy /sec
>> Ethtool(enp175s0f0) stat:      1781569 (      1,781,569) <= rx_cache_reuse /sec
>> Ethtool(enp175s0f0) stat:      8900603 (      8,900,603) <= rx_csum_complete /sec
>> Ethtool(enp175s0f0) stat:      1773785 (      1,773,785) <= rx_out_of_buffer /sec
>> Ethtool(enp175s0f0) stat:      8900603 (      8,900,603) <= rx_packets /sec
>> Ethtool(enp175s0f0) stat:     10674799 (     10,674,799) <= rx_packets_phy /sec
>> Ethtool(enp175s0f0) stat:      7118993 (      7,118,993) <= rx_page_reuse /sec
>> Ethtool(enp175s0f0) stat:    768565744 (    768,565,744) <= rx_prio0_bytes /sec
>> Ethtool(enp175s0f0) stat:     10674522 (     10,674,522) <= rx_prio0_packets /sec
>> Ethtool(enp175s0f0) stat:    725871089 (    725,871,089) <= rx_vport_unicast_bytes /sec
>> Ethtool(enp175s0f0) stat:     10674575 (     10,674,575) <= rx_vport_unicast_packets /sec
>
> It looks like the mlx5 page recycle mechanism works:
>
>     230413 (        230,413) <= rx7_cache_reuse /sec
>   + 926376 (        926,376) <= rx7_page_reuse /sec
>   =1156789 (230413+926376)
>   -1156775 (      1,156,775) <= rx7_packets /sec
>   =     14
>
> You can also determine this as there are no counters for:
>   rx_cache_full or
>   rx_cache_empty or
>   rx1_cache_empty
>   rx1_cache_busy
>
>   
>> For TX nic with vlan:
>> Show adapter(s) (enp175s0f1) statistics (ONLY that changed!)
>> Ethtool(enp175s0f1) stat:            1 (              1) <= rx_65_to_127_bytes_phy /sec
>> Ethtool(enp175s0f1) stat:           71 (             71) <= rx_bytes_phy /sec
>> Ethtool(enp175s0f1) stat:            1 (              1) <= rx_multicast_phy /sec
>> Ethtool(enp175s0f1) stat:            1 (              1) <= rx_packets_phy /sec
>> Ethtool(enp175s0f1) stat:           71 (             71) <= rx_prio0_bytes /sec
>> Ethtool(enp175s0f1) stat:            1 (              1) <= rx_prio0_packets /sec
>> Ethtool(enp175s0f1) stat:           67 (             67) <= rx_vport_multicast_bytes /sec
>> Ethtool(enp175s0f1) stat:            1 (              1) <= rx_vport_multicast_packets /sec
>> Ethtool(enp175s0f1) stat:     64955114 (     64,955,114) <= tx0_bytes /sec
>> Ethtool(enp175s0f1) stat:       955222 (        955,222) <= tx0_csum_none /sec
>> Ethtool(enp175s0f1) stat:        26489 (         26,489) <= tx0_nop /sec
>> Ethtool(enp175s0f1) stat:       955222 (        955,222) <= tx0_packets /sec
>> Ethtool(enp175s0f1) stat:     66799214 (     66,799,214) <= tx1_bytes /sec
>> Ethtool(enp175s0f1) stat:       982341 (        982,341) <= tx1_csum_none /sec
>> Ethtool(enp175s0f1) stat:        27225 (         27,225) <= tx1_nop /sec
>> Ethtool(enp175s0f1) stat:       982341 (        982,341) <= tx1_packets /sec
>> Ethtool(enp175s0f1) stat:     78650421 (     78,650,421) <= tx2_bytes /sec
>> Ethtool(enp175s0f1) stat:      1156624 (      1,156,624) <= tx2_csum_none /sec
>> Ethtool(enp175s0f1) stat:        32059 (         32,059) <= tx2_nop /sec
>> Ethtool(enp175s0f1) stat:      1156624 (      1,156,624) <= tx2_packets /sec
>> Ethtool(enp175s0f1) stat:     78186849 (     78,186,849) <= tx3_bytes /sec
>> Ethtool(enp175s0f1) stat:      1149807 (      1,149,807) <= tx3_csum_none /sec
>> Ethtool(enp175s0f1) stat:        31879 (         31,879) <= tx3_nop /sec
>> Ethtool(enp175s0f1) stat:      1149807 (      1,149,807) <= tx3_packets /sec
>> Ethtool(enp175s0f1) stat:          234 (            234) <= tx3_xmit_more /sec
>> Ethtool(enp175s0f1) stat:     78466099 (     78,466,099) <= tx4_bytes /sec
>> Ethtool(enp175s0f1) stat:      1153913 (      1,153,913) <= tx4_csum_none /sec
>> Ethtool(enp175s0f1) stat:        31990 (         31,990) <= tx4_nop /sec
>> Ethtool(enp175s0f1) stat:      1153913 (      1,153,913) <= tx4_packets /sec
>> Ethtool(enp175s0f1) stat:     78765724 (     78,765,724) <= tx5_bytes /sec
>> Ethtool(enp175s0f1) stat:      1158319 (      1,158,319) <= tx5_csum_none /sec
>> Ethtool(enp175s0f1) stat:        32115 (         32,115) <= tx5_nop /sec
>> Ethtool(enp175s0f1) stat:      1158319 (      1,158,319) <= tx5_packets /sec
>> Ethtool(enp175s0f1) stat:          264 (            264) <= tx5_xmit_more /sec
>> Ethtool(enp175s0f1) stat:     79669524 (     79,669,524) <= tx6_bytes /sec
>> Ethtool(enp175s0f1) stat:      1171611 (      1,171,611) <= tx6_csum_none /sec
>> Ethtool(enp175s0f1) stat:        32490 (         32,490) <= tx6_nop /sec
>> Ethtool(enp175s0f1) stat:      1171611 (      1,171,611) <= tx6_packets /sec
>> Ethtool(enp175s0f1) stat:     79389329 (     79,389,329) <= tx7_bytes /sec
>> Ethtool(enp175s0f1) stat:      1167490 (      1,167,490) <= tx7_csum_none /sec
>> Ethtool(enp175s0f1) stat:        32365 (         32,365) <= tx7_nop /sec
>> Ethtool(enp175s0f1) stat:      1167490 (      1,167,490) <= tx7_packets /sec
>> Ethtool(enp175s0f1) stat:    604885175 (    604,885,175) <= tx_bytes /sec
>> Ethtool(enp175s0f1) stat:    676059749 (    676,059,749) <= tx_bytes_phy /sec
>> Ethtool(enp175s0f1) stat:      8895370 (      8,895,370) <= tx_packets /sec
>> Ethtool(enp175s0f1) stat:      8895522 (      8,895,522) <= tx_packets_phy /sec
>> Ethtool(enp175s0f1) stat:    676063067 (    676,063,067) <= tx_prio0_bytes /sec
>> Ethtool(enp175s0f1) stat:      8895566 (      8,895,566) <= tx_prio0_packets /sec
>> Ethtool(enp175s0f1) stat:    640470657 (    640,470,657) <= tx_vport_unicast_bytes /sec
>> Ethtool(enp175s0f1) stat:      8895427 (      8,895,427) <= tx_vport_unicast_packets /sec
>> Ethtool(enp175s0f1) stat:          498 (            498) <= tx_xmit_more /sec
> We are seeing some xmit_more, this is interesting.  Have you noticed,
> if (in the VLAN case) there is a queue in the qdisc layer?
>
> Simply inspect with: tc -s qdisc show dev ixgbe2
for vlan no qdisc:
tc -s -d qdisc show dev vlan1000

qdisc noqueue 0: root refcnt 2
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0

physical interface mq attached with pfifo_fast:

tc -s -d qdisc show dev enp175s0f1
qdisc mq 0: root
  Sent 1397200697212 bytes 3965888669 pkt (dropped 78065663, overlimits 
0 requeues 629868)
  backlog 0b 0p requeues 629868
qdisc pfifo_fast 0: parent :38 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :37 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :36 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :35 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :34 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :33 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :32 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :31 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :30 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :2f bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :2e bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :2d bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :2c bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :2b bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :2a bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :29 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :28 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :27 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :26 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :25 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :24 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :23 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :22 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :21 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :20 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :1f bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :1e bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :1d bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :1c bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :1b bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :1a bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :19 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :18 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 176 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :17 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :16 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :15 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :14 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :13 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :12 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :11 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
qdisc pfifo_fast 0: parent :10 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1
  Sent 18534143578 bytes 289595993 pkt (dropped 0, overlimits 0 requeues 
1191)
  backlog 0b 0p requeues 1191
qdisc pfifo_fast 0: parent :f bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 17022213952 bytes 265972093 pkt (dropped 0, overlimits 0 requeues 
1126)
  backlog 0b 0p requeues 1126
qdisc pfifo_fast 0: parent :e bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 19610732552 bytes 306417696 pkt (dropped 0, overlimits 0 requeues 
147499)
  backlog 0b 0p requeues 147499
qdisc pfifo_fast 0: parent :d bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 18153006206 bytes 283640721 pkt (dropped 0, overlimits 0 requeues 
171576)
  backlog 0b 0p requeues 171576
qdisc pfifo_fast 0: parent :c bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 20642461846 bytes 322538466 pkt (dropped 0, overlimits 0 requeues 
67124)
  backlog 0b 0p requeues 67124
qdisc pfifo_fast 0: parent :b bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 19343910144 bytes 302248596 pkt (dropped 0, overlimits 0 requeues 
224627)
  backlog 0b 0p requeues 224627
qdisc pfifo_fast 0: parent :a bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 20735716968 bytes 323995576 pkt (dropped 0, overlimits 0 requeues 
1451)
  backlog 0b 0p requeues 1451
qdisc pfifo_fast 0: parent :9 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 19371526272 bytes 302680098 pkt (dropped 0, overlimits 0 requeues 
2244)
  backlog 0b 0p requeues 2244
qdisc pfifo_fast 0: parent :8 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 162202525454 bytes 2444195441 pkt (dropped 31716535, overlimits 0 
requeues 2456)
  backlog 0b 0p requeues 2456
qdisc pfifo_fast 0: parent :7 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 163308408548 bytes 2461561759 pkt (dropped 0, overlimits 0 
requeues 1454)
  backlog 0b 0p requeues 1454
qdisc pfifo_fast 0: parent :6 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 164214830346 bytes 2475734074 pkt (dropped 19272, overlimits 0 
requeues 2216)
  backlog 0b 0p requeues 2216
qdisc pfifo_fast 0: parent :5 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 160398101830 bytes 2417635038 pkt (dropped 0, overlimits 0 
requeues 1509)
  backlog 0b 0p requeues 1509
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 161760263056 bytes 2437965677 pkt (dropped 0, overlimits 0 
requeues 1442)
  backlog 0b 0p requeues 1442
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 160300203040 bytes 2415206290 pkt (dropped 0, overlimits 0 
requeues 1615)
  backlog 0b 0p requeues 1615
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 140144336184 bytes 2114089739 pkt (dropped 0, overlimits 0 
requeues 1177)
  backlog 0b 0p requeues 1177
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 
1 1 1
  Sent 131458317060 bytes 1982280594 pkt (dropped 46329856, overlimits 0 
requeues 1161)
  backlog 0b 0p requeues 1161



>
>
>>>   
>>>> ethtool settings for both tests:
>>>> ifc='enp175s0f0 enp175s0f1'
>>>> for i in $ifc
>>>>            do
>>>>            ip link set up dev $i
>>>>            ethtool -A $i autoneg off rx off tx off
>>>>            ethtool -G $i rx 128 tx 256
>>> The ring queue size recommendations, might be different for the mlx5
>>> driver (Cc'ing Mellanox maintainers).
>>>
>>>   
>>>>            ip link set $i txqueuelen 1000
>>>>            ethtool -C $i rx-usecs 25
>>>>            ethtool -L $i combined 16
>>>>            ethtool -K $i gro off tso off gso off sg on l2-fwd-offload off
>>>> tx-nocache-copy off ntuple on
>>>>            ethtool -N $i rx-flow-hash udp4 sdfn
>>>>            done
>>> Thanks for being explicit about what you setup is :-)
>>>      
>>>> and perf top:
>>>>       PerfTop:   83650 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz
>>>> cycles],  (all, 56 CPUs)
>>>> ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>>>>
>>>>        14.25%  [kernel]       [k] dst_release
>>>>        14.17%  [kernel]       [k] skb_dst_force
>>>>        13.41%  [kernel]       [k] rt_cache_valid
>>>>        11.47%  [kernel]       [k] ip_finish_output2
>>>>         7.01%  [kernel]       [k] do_raw_spin_lock
>>>>         5.07%  [kernel]       [k] page_frag_free
>>>>         3.47%  [mlx5_core]    [k] mlx5e_xmit
>>>>         2.88%  [kernel]       [k] fib_table_lookup
>>>>         2.43%  [mlx5_core]    [k] skb_from_cqe.isra.32
>>>>         1.97%  [kernel]       [k] virt_to_head_page
>>>>         1.81%  [mlx5_core]    [k] mlx5e_poll_tx_cq
>>>>         0.93%  [kernel]       [k] __dev_queue_xmit
>>>>         0.87%  [kernel]       [k] __build_skb
>>>>         0.84%  [kernel]       [k] ipt_do_table
>>>>         0.79%  [kernel]       [k] ip_rcv
>>>>         0.79%  [kernel]       [k] acpi_processor_ffh_cstate_enter
>>>>         0.78%  [kernel]       [k] netif_skb_features
>>>>         0.73%  [kernel]       [k] __netif_receive_skb_core
>>>>         0.52%  [kernel]       [k] dev_hard_start_xmit
>>>>         0.52%  [kernel]       [k] build_skb
>>>>         0.51%  [kernel]       [k] ip_route_input_rcu
>>>>         0.50%  [kernel]       [k] skb_unref
>>>>         0.49%  [kernel]       [k] ip_forward
>>>>         0.48%  [mlx5_core]    [k] mlx5_cqwq_get_cqe
>>>>         0.44%  [kernel]       [k] udp_v4_early_demux
>>>>         0.41%  [kernel]       [k] napi_consume_skb
>>>>         0.40%  [kernel]       [k] __local_bh_enable_ip
>>>>         0.39%  [kernel]       [k] ip_rcv_finish
>>>>         0.39%  [kernel]       [k] kmem_cache_alloc
>>>>         0.38%  [kernel]       [k] sch_direct_xmit
>>>>         0.33%  [kernel]       [k] validate_xmit_skb
>>>>         0.32%  [mlx5_core]    [k] mlx5e_free_rx_wqe_reuse
>>>>         0.29%  [kernel]       [k] netdev_pick_tx
>>>>         0.28%  [mlx5_core]    [k] mlx5e_build_rx_skb
>>>>         0.27%  [kernel]       [k] deliver_ptype_list_skb
>>>>         0.26%  [kernel]       [k] fib_validate_source
>>>>         0.26%  [mlx5_core]    [k] mlx5e_napi_poll
>>>>         0.26%  [mlx5_core]    [k] mlx5e_handle_rx_cqe
>>>>         0.26%  [mlx5_core]    [k] mlx5e_rx_cache_get
>>>>         0.25%  [kernel]       [k] eth_header
>>>>         0.23%  [kernel]       [k] skb_network_protocol
>>>>         0.20%  [kernel]       [k] nf_hook_slow
>>>>         0.20%  [kernel]       [k] vlan_passthru_hard_header
>>>>         0.20%  [kernel]       [k] vlan_dev_hard_start_xmit
>>>>         0.19%  [kernel]       [k] swiotlb_map_page
>>>>         0.18%  [kernel]       [k] compound_head
>>>>         0.18%  [kernel]       [k] neigh_connected_output
>>>>         0.18%  [mlx5_core]    [k] mlx5e_alloc_rx_wqe
>>>>         0.18%  [kernel]       [k] ip_output
>>>>         0.17%  [kernel]       [k] prefetch_freepointer.isra.70
>>>>         0.17%  [kernel]       [k] __slab_free
>>>>         0.16%  [kernel]       [k] eth_type_vlan
>>>>         0.16%  [kernel]       [k] ip_finish_output
>>>>         0.15%  [kernel]       [k] kmem_cache_free_bulk
>>>>         0.14%  [kernel]       [k] netif_receive_skb_internal
>>>>
>>>>
>>>>
>>>>
>>>> wondering why this:
>>>>         1.97%  [kernel]       [k] virt_to_head_page
>>>> is in top...
>>> This is related to the page_frag_free() call, but it is weird that it
>>> shows up because it is suppose to be inlined (it is explicitly marked
>>> inline in include/linux/mm.h).
>>>
>>>   
>>>>>>>>> perf top:
>>>>>>>>>
>>>>>>>>>       PerfTop:   77835 irqs/sec  kernel:99.7%
>>>>>>>>> ---------------------------------------------
>>>>>>>>>
>>>>>>>>>          16.32%  [kernel]       [k] skb_dst_force
>>>>>>>>>          16.30%  [kernel]       [k] dst_release
>>>>>>>>>          15.11%  [kernel]       [k] rt_cache_valid
>>>>>>>>>          12.62%  [kernel]       [k] ipv4_mtu
>>>>>>>> It seems a little strange that these 4 functions are on the top
>>>>> I don't see these in my test.
>>>>>      
>>>>>>>>         
>>>>>>>>>           5.60%  [kernel]       [k] do_raw_spin_lock
>>>>>>>> Why is calling/taking this lock? (Use perf call-graph recording).
>>>>>>> can be hard to paste it here:)
>>>>>>> attached file
>>>>> The attached was very big. Please don't attach so big file on mailing
>>>>> lists.  Next time plase share them via e.g. pastebin. The output was a
>>>>> capture from your terminal, which made the output more difficult to
>>>>> read.  Hint: You can/could use perf --stdio and place it in a file
>>>>> instead.
>>>>>
>>>>> The output (extracted below) didn't show who called 'do_raw_spin_lock',
>>>>> BUT it showed another interesting thing.  The kernel code
>>>>> __dev_queue_xmit() in might create route dst-cache problem for itself(?),
>>>>> as it will first call skb_dst_force() and then skb_dst_drop() when the
>>>>> packet is transmitted on a VLAN.
>>>>>
>>>>>     static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>>>>>     {
>>>>>     [...]
>>>>> 	/* If device/qdisc don't need skb->dst, release it right now while
>>>>> 	 * its hot in this cpu cache.
>>>>> 	 */
>>>>> 	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>>>>> 		skb_dst_drop(skb);
>>>>> 	else
>>>>> 		skb_dst_force(skb);
>>>>>
>
