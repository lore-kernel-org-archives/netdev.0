From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Sun, 13 Aug 2017 18:58:58 +0200
Message-ID: <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
 <20170812142358.08291888@redhat.com>
 <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7.iq.pl ([86.111.240.244]:58881 "EHLO smtp7.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751024AbdHMRAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Aug 2017 13:00:16 -0400
In-Reply-To: <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To show some difference below comparision vlan/no-vlan traffic

10Mpps forwarded traffic vith no-vlan vs 6.9Mpps with vlan

(ixgbe in kernel driver kernel 4.13.0-rc4-next-20170811)

ethtool settings for both tests:

ethtool -K $ifc gro off tso off gso off sg on l2-fwd-offload off 
tx-nocache-copy off ntuple off

ethtool -L $ifc combined 16

ethtool -C $ifc rx-usecs 2

ethtool -G $ifc rx 4096 tx 1024

16 CORES / 16 RSS QUEUES


Tx traffic on vlan:

RX Interface:

enp216s0f0

TX Interface

vlan1000 added to enp216s0f1 interface (with vlan 1000 ip address assigned)

ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
0;16;64;6939008;416325120;6938696;402411192
1;16;64;6941952;416444160;6941745;402558918
2;16;64;6960576;417584640;6960707;403698718
3;16;64;6940736;416486400;6941820;402503876
4;16;64;6927680;415741440;6927420;401853870
5;16;64;6929792;415687680;6929917;401839196
6;16;64;6950400;416989440;6950661;403026166
7;16;64;6953664;417216000;6953454;403260544
8;16;64;6948480;416851200;6948800;403023266
9;16;64;6924160;415422720;6924092;401542468

100% load on all 16 Cores.


vs

RX interface from traffic generator:

enp216s0f0

TX interface to the sink:

enp216s0f1

No vlan used

ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX

0;16;64;10280176;793608540;10298496;596796568
1;16;64;10046928;600978780;10046022;582527002
2;16;64;10032956;601827420;10026097;581515656
3;16;64;10051503;602252460;10067880;582420804
4;16;64;10016204;602725140;10017358;582644800
5;16;64;10035575;602437620;10059504;582067294
6;16;64;10041667;603069780;10057865;582477412
7;16;64;10044448;600027420;10046526;581022018
8;16;64;10022436;601121100;10025946;581904314
9;16;64;10036231;602514960;10058724;582180684


So we have 10Mpps forwarded

- have problems with pktgen on my traffic generator to push more than 
10M but this low budget hardware so.. :)


And there are still free cpu cycles so probabbly can forward at line 10G 
rate 14Mpps

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft %steal  
%guest  %gnice   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00 20.91    
0.00    0.00    0.00   79.09
Average:       0    0.00    0.00    0.00    0.00    0.00 0.09    0.00    
0.00    0.00   99.91
Average:       1    0.03    0.00    0.03    0.00    0.00 0.00    0.00    
0.00    0.00   99.94
Average:       2    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       3    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       4    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       5    0.00    0.00    0.18    0.00    0.00 0.00    0.00    
0.00    0.00   99.82
Average:       6    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       7    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       8    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       9    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      10    0.00    0.00    0.03    0.24    0.00 0.00    0.00    
0.00    0.00   99.74
Average:      11    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      12    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      13    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      14    0.00    0.00    0.00    0.00    0.00 92.38    
0.00    0.00    0.00    7.62
Average:      15    0.00    0.00    0.00    0.00    0.00 85.88    
0.00    0.00    0.00   14.12
Average:      16    0.00    0.00    0.00    0.00    0.00 64.91    
0.00    0.00    0.00   35.09
Average:      17    0.00    0.00    0.00    0.00    0.00 66.76    
0.00    0.00    0.00   33.24
Average:      18    0.00    0.00    0.00    0.00    0.00 65.57    
0.00    0.00    0.00   34.43
Average:      19    0.00    0.00    0.00    0.00    0.00 66.38    
0.00    0.00    0.00   33.62
Average:      20    0.00    0.00    0.00    0.00    0.00 72.97    
0.00    0.00    0.00   27.03
Average:      21    0.00    0.00    0.00    0.00    0.00 70.80    
0.00    0.00    0.00   29.20
Average:      22    0.00    0.00    0.00    0.00    0.00 66.44    
0.00    0.00    0.00   33.56
Average:      23    0.00    0.00    0.00    0.00    0.00 66.12    
0.00    0.00    0.00   33.88
Average:      24    0.00    0.00    0.00    0.00    0.00 68.35    
0.00    0.00    0.00   31.65
Average:      25    0.00    0.00    0.00    0.00    0.00 71.79    
0.00    0.00    0.00   28.21
Average:      26    0.00    0.00    0.00    0.00    0.00 70.24    
0.00    0.00    0.00   29.76
Average:      27    0.00    0.00    0.00    0.00    0.00 73.24    
0.00    0.00    0.00   26.76
Average:      28    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      29    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      30    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      31    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      32    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      33    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      34    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      35    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      36    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      37    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      38    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      39    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      40    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      41    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      42    0.00    0.00    0.00    0.00    0.00 84.27    
0.00    0.00    0.00   15.73
Average:      43    0.00    0.00    0.00    0.00    0.00 84.50    
0.00    0.00    0.00   15.50
Average:      44    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      45    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      46    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      47    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      48    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      49    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      50    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      51    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      52    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      53    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      54    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      55    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00

Average:     CPU    intr/s
Average:     all 3559661.68
Average:       0    628.53
Average:       1    537.62
Average:       2    525.00
Average:       3    558.29
Average:       4    546.79
Average:       5    522.85
Average:       6    508.06
Average:       7    568.88
Average:       8    529.56
Average:       9    535.29
Average:      10    530.09
Average:      11    539.53
Average:      12    520.82
Average:      13    531.32
Average:      14  73315.68
Average:      15 115983.15
Average:      16 254446.09
Average:      17 253067.79
Average:      18 254446.35
Average:      19 252457.29
Average:      20 213928.18
Average:      21 232770.32
Average:      22 263906.85
Average:      23 260065.09
Average:      24 243609.74
Average:      25 218122.53
Average:      26 237405.38
Average:      27 217582.76
Average:      28    548.29
Average:      29    569.12
Average:      30    540.74
Average:      31    517.50
Average:      32    521.59
Average:      33    544.85
Average:      34    520.91
Average:      35    553.29
Average:      36    545.32
Average:      37    518.44
Average:      38    557.26
Average:      39    541.71
Average:      40    515.21
Average:      41    520.82
Average:      42 137722.38
Average:      43 135737.59
Average:      44    524.97
Average:      45    538.24
Average:      46    580.38
Average:      47    567.62
Average:      48    555.53
Average:      49    561.50
Average:      50    537.65
Average:      51    565.09
Average:      52    536.12
Average:      53    570.44
Average:      54    535.38
Average:      55    567.88

Average:     CPU       HI/s    TIMER/s   NET_TX/s   NET_RX/s BLOCK/s 
IRQ_POLL/s  TASKLET/s    SCHED/s  HRTIMER/s      RCU/s
Average:       0       0.00     250.03       0.18      69.09 0.00       
0.00       6.59     250.03       0.00      52.62
Average:       1       0.00     228.94       0.00       0.00 0.00       
0.00      10.82     249.79       0.00      48.06
Average:       2       0.00     244.53       0.00       0.00 0.00       
0.00       0.00     249.79       0.00      30.68
Average:       3       0.00     249.53       0.00       0.00 0.00       
0.00       0.00     249.91       0.00      58.85
Average:       4       0.00     243.71       0.00       0.00 0.00       
0.00       0.00     249.94       0.00      53.15
Average:       5       0.00     247.06       0.00       0.00 0.00       
0.00       0.00     249.44       0.00      26.35
Average:       6       0.00     249.38       0.00       0.00 0.00       
0.00       0.00     249.91       0.00       8.76
Average:       7       0.00     226.03       0.00       0.00 0.00       
0.00       0.00     249.88       0.00      92.97
Average:       8       0.00     244.29       0.00       0.00 0.00       
0.00       0.00     249.79       0.00      35.47
Average:       9       0.00     247.71       0.00       0.00 0.00       
0.00       0.00     249.94       0.00      37.65
Average:      10       0.00     241.85       0.00       0.00 0.00       
0.00       0.00     249.65       0.00      38.59
Average:      11       0.00     249.00       0.00       0.00 0.00       
0.00       0.00     249.94       0.00      40.59
Average:      12       0.00     248.85       0.00       0.00 0.00       
0.00       0.00     249.88       0.00      22.09
Average:      13       0.00     249.12       0.00       0.00 0.00       
0.00       0.00     249.88       0.00      32.32
Average:      14       0.00     212.97     147.44   72760.47 0.00       
0.00       0.00     189.35       0.00       5.44
Average:      15       0.00     233.94     139.21  115367.26 0.00       
0.00       0.00     225.03       0.00      17.71
Average:      16       0.00     245.41     158.94  253784.06 0.00       
0.00       0.00     244.65       0.00      13.03
Average:      17       0.00     245.74     164.09  252402.41 0.00       
0.00       0.00     244.85       0.00      10.71
Average:      18       0.00     245.56     161.32  253778.00 0.00       
0.00       0.00     244.97       0.00      16.50
Average:      19       0.00     245.38     161.35  251789.41 0.00       
0.00       0.00     244.53       0.00      16.62
Average:      20       0.00     244.97     201.59  213226.74 0.00       
0.00       0.00     244.24       0.00      10.65
Average:      21       0.00     245.59     174.82  232072.85 0.00       
0.00       0.00     244.82       0.00      32.24
Average:      22       0.00     245.44     157.47  263244.59 0.00       
0.00       0.00     244.74       0.00      14.62
Average:      23       0.00     245.53     165.09  259398.41 0.00       
0.00       0.00     244.94       0.00      11.12
Average:      24       0.00     245.38     179.47  242922.85 0.00       
0.00       0.00     244.85       0.00      17.18
Average:      25       0.00     245.47     195.15  217419.79 0.00       
0.00       0.00     244.50       0.00      17.62
Average:      26       0.00     245.41     182.18  236714.38 0.00       
0.00       0.00     244.62       0.00      18.79
Average:      27       0.00     244.94     196.65  216886.68 0.00       
0.00       0.00     244.44       0.00      10.06
Average:      28       0.00     247.35       0.00       0.00 0.00       
0.00       0.00     249.91       0.00      51.03
Average:      29       0.00     228.94       0.00       0.00 0.00       
0.00       0.00     249.79       0.00      90.38
Average:      30       0.00     244.50       0.00       0.00 0.00       
0.00       0.00     249.82       0.00      46.41
Average:      31       0.00     249.53       0.00       0.00 0.00       
0.00       0.00     249.97       0.00      18.00
Average:      32       0.00     243.82       0.00       0.00 0.00       
0.00       0.00     249.97       0.00      27.79
Average:      33       0.00     247.03       0.00       0.00 0.00       
0.00       0.00     249.47       0.00      48.35
Average:      34       0.00     249.38       0.00       0.00 0.00       
0.00       0.00     249.94       0.00      21.59
Average:      35       0.00     226.00       0.00       0.00 0.00       
0.00       0.00     249.88       0.00      77.41
Average:      36       0.00     244.29       0.00       0.00 0.00       
0.00       0.00     249.85       0.00      51.18
Average:      37       0.00     247.71       0.00       0.00 0.00       
0.00       0.00     249.97       0.00      20.76
Average:      38       0.00     241.85       0.00       0.00 0.00       
0.00       0.00     249.68       0.00      65.74
Average:      39       0.00     249.00       0.00       0.00 0.00       
0.00       0.00     249.94       0.00      42.76
Average:      40       0.00     248.85       0.00       0.00 0.00       
0.00       0.00     249.85       0.00      16.50
Average:      41       0.00     249.12       0.00       0.00 0.00       
0.00       0.00     249.94       0.00      21.76
Average:      42       0.00     240.26     112.85  137160.06 0.00       
0.00       0.00     203.44       0.00       5.76
Average:      43       0.00     237.91     122.91  135139.38 0.00       
0.00       0.00     231.79       0.00       5.59
Average:      44       0.00     249.15       0.00       0.00 0.00       
0.00       0.00     248.26       0.00      27.56
Average:      45       0.00     249.26       0.00       0.00 0.00       
0.00       0.00     248.62       0.00      40.35
Average:      46       0.00     249.26       0.00       0.00 0.00       
0.00       0.00     248.47       0.00      82.65
Average:      47       0.00     249.26       0.00       0.00 0.00       
0.00       0.00     248.50       0.00      69.85
Average:      48       0.00     249.09       0.00       0.00 0.00       
0.00       0.00     248.38       0.00      58.06
Average:      49       0.00     249.32       0.00       0.00 0.00       
0.00       0.00     248.59       0.00      63.59
Average:      50       0.00     249.35       0.00       0.00 0.00       
0.00       0.00     248.32       0.00      39.97
Average:      51       0.00     249.24       0.00       0.00 0.00       
0.00       0.00     248.29       0.00      67.56
Average:      52       0.00     249.18       0.00       0.00 0.00       
0.00       0.00     247.91       0.00      39.03
Average:      53       0.00     249.18       0.00       0.00 0.00       
0.00       0.00     248.41       0.00      72.85
Average:      54       0.00     249.18       0.00       0.00 0.00       
0.00       0.00     248.06       0.00      38.15
Average:      55       0.00     249.41       0.18       0.00 0.00       
0.00       0.00     248.71       0.00      69.59



W dniu 2017-08-12 o 19:27, Paweł Staszewski pisze:
> Hi and thanks for reply
>
>
>
> W dniu 2017-08-12 o 14:23, Jesper Dangaard Brouer pisze:
>> On Fri, 11 Aug 2017 19:51:10 +0200 Paweł Staszewski 
>> <pstaszewski@itcare.pl> wrote:
>>
>>> Hi
>>>
>>> I made some tests for performance comparison.
>> Thanks for doing this. Feel free to Cc me, if you do more of these
>> tests (so I don't miss them on the mailing list).
>>
>> I don't understand stand if you are reporting a potential problem?
>>
>> It would be good if you can provide a short summary section (of the
>> issue) in the _start_ of the email, and then provide all this nice data
>> afterwards, to back your case.
>>
>> My understanding is, you report:
>>
>> 1. VLANs on ixgbe show a 30-40% slowdown
>> 2. System stopped scaling after 7+ CPUs
> This is not only problem/bug report  - but some kind of comparision 
> plus some toughts about possible problems :)
> And can help somebody when searching the net for possible expectations :)
> Also - dono better list where are the smartest people that know what 
> is going in kernel with networking :)
>
> Next time i will place summary on top - sorry :)
>
>>
>>> Tested HW (FORWARDING HOST):
>>>
>>> Intel(R) Xeon(R) Gold 6132 CPU @ 2.60GHz
>> Interesting, I've not heard about a Intel CPU called "Gold" before now,
>> but it does exist:
>> https://ark.intel.com/products/123541/Intel-Xeon-Gold-6132-Processor-19_25M-Cache-2_60-GHz
>>
>>
>>> Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection 
>>> (rev 01)
>> This is one of my all time favorite NICs!
> Yes this is a good NIC - will have connectx-4 2x100G by monday so will 
> also do some tests
>
>>> Test diagram:
>>>
>>>
>>> TRAFFIC GENERATOR (ethX) -> (enp216s0f0 - RX Traffic) FORWARDING HOST
>>> (enp216s0f1(vlan1000) - TX Traffic) -> (ethY) SINK
>>>
>>> Forwarder traffic: UDP random ports from 9 to 19 with random hosts from
>>> 172.16.0.1 to 172.16.0.255
>>>
>>> TRAFFIC GENERATOR TX is stable 9.9Mpps (in kernel pktgen)
>> What kind of traffic flow?  E.g. distribution, many/few source IPs...
>
> Traffic generator is pktgen so udp flows - better paste parameters 
> from pktgen:
>     UDP_MIN=9
>     UDP_MAX=19
>
>     pg_set $dev "dst_min 172.16.0.1"
>     pg_set $dev "dst_max 172.16.0.100"
>
>     # Setup random UDP port src range
>     #pg_set $dev "flag UDPSRC_RND"
>     pg_set $dev "flag UDPSRC_RND"
>     pg_set $dev "udp_src_min $UDP_MIN"
>     pg_set $dev "udp_src_max $UDP_MAX"
>
>
>>
>>> Settings used for FORWARDING HOST (changed param. was only number of 
>>> RSS
>>> combined queues + set affinity assignment for them to fit with first
>>> numa node where 2x10G port card is installed)
>>>
>>> ixgbe driver used from kernel (in-kernel build - not a module)
>>>
>> Nice with a script showing you setup, thanks. I would be good if it had
>> comments, telling why you think this is a needed setup adjustment.
>>
>>> #!/bin/sh
>>> ifc='enp216s0f0 enp216s0f1'
>>> for i in $ifc
>>>           do
>>>           ip link set up dev $i
>>>           ethtool -A $i autoneg off rx off tx off
>> Good:
>>   Turning off Ethernet flow control, to avoid receiver being the
>>   bottleneck via pause-frames.
> Yes - enabled flow controll is really bad :)
>>>           ethtool -G $i rx 4096 tx 1024
>> You adjust the RX and TX ring queue sizes, this have effects that you
>> don't realize.  Especially for the ixgbe driver, which have a page
>> recycle trick tied to the RX ring queue size.
> rx ring 4096 and tx ring 1024
> - this is because have best performance then with average packet size 
> from 64 to 1500 bytes
>
> Can be a little better performance for smaller frames like 64 - with 
> rx ring set to 1024
> below 1 core/1 RSS queue with rx ring set to 1024
>
> 0;1;64;1530112;91772160;1529919;88724208
> 1;1;64;1531584;91872000;1531520;88813196
> 2;1;64;1531392;91895040;1531262;88831930
> 3;1;64;1530880;91875840;1531201;88783558
> 4;1;64;1530688;91829760;1530688;88768826
> 5;1;64;1530432;91810560;1530624;88764940
> 6;1;64;1530880;91868160;1530878;88787328
> 7;1;64;1530496;91845120;1530560;88765114
> 8;1;64;1530496;91837440;1530687;88772538
> 9;1;64;1530176;91795200;1530496;88735360
>
> so from 1.47Mpps to 1.53Mpps
>
> But with bigger packets > 200 performance is better when rx is set to 
> 4096
>
>
>>
>>>           ip link set $i txqueuelen 1000
>> Setting tx queue len to the default 1000 seems redundant.
> Yes cause i'm changing this parameter also to see if any impact on 
> performance we have
>>
>>>           ethtool -C $i rx-usecs 10
>> Adjusting this also have effects you might not realize.  This actually
>> also affect the page recycle scheme of ixgbe.  And can sometimes be
>> used to solve stalling on DMA TX completions, which could be you issue
>> here.
> same here - rx-usecs - setting to 10 was kind of compromise to have 
> good performance with big ans small packet sizes
>
> Same test as above with rx ring 1024 tx ring 1024 and rxusecs set to 
> 256 (1Core/1RSS queue):
> 0;1;64;1506304;90424320;1506626;87402868
> 1;1;64;1505536;90343680;1504830;87321088
> 2;1;64;1506880;90416640;1507522;87388120
> 3;1;64;1511040;90700800;1511682;87684864
> 4;1;64;1511040;90681600;1511102;87662476
> 5;1;64;1511488;90712320;1511614;87673728
> 6;1;64;1511296;90700800;1511038;87669900
> 7;1;64;1513344;90773760;1513280;87751680
> 8;1;64;1513536;90850560;1513470;87807360
> 9;1;64;1512128;90696960;1512000;87696000
>
> And rx-usecs set to 1
> 0;1;64;1533632;92037120;1533504;88954368
> 1;1;64;1533632;92006400;1533570;88943348
> 2;1;64;1533504;91994880;1533504;88931980
> 3;1;64;1532864;91979520;1532674;88902516
> 4;1;64;1533952;92044800;1534080;88961792
> 5;1;64;1533888;92048640;1534270;88969100
> 6;1;64;1533952;92037120;1534082;88969216
> 7;1;64;1533952;92021760;1534208;88969332
> 8;1;64;1533056;91983360;1532930;88883724
> 9;1;64;1533760;92021760;1533886;88946828
>
> rx-useck set to 2
> 0;1;64;1522432;91334400;1522304;88301056
> 1;1;64;1521920;91330560;1522496;88286208
> 2;1;64;1522496;91322880;1522432;88304768
> 3;1;64;1523456;91422720;1523649;88382762
> 4;1;64;1527680;91676160;1527424;88601728
> 5;1;64;1527104;91626240;1526912;88572032
> 6;1;64;1527424;91641600;1527424;88590592
> 7;1;64;1526336;91572480;1526912;88523776
> 8;1;64;1527040;91637760;1526912;88579456
> 9;1;64;1527040;91595520;1526784;88553472
>
> rx-usecs set to 3
> 0;1;64;1526272;91549440;1526592;88527488
> 1;1;64;1526528;91560960;1526272;88516352
> 2;1;64;1525952;91580160;1525888;88527488
> 3;1;64;1525504;91511040;1524864;88456960
> 4;1;64;1526272;91568640;1526208;88494080
> 5;1;64;1525568;91545600;1525312;88494080
> 6;1;64;1526144;91584000;1526080;88512640
> 7;1;64;1525376;91530240;1525376;88482944
> 8;1;64;1526784;91607040;1526592;88549760
> 9;1;64;1526208;91560960;1526528;88512640
>
>
>>
>>>           ethtool -L $i combined 16
>>>           ethtool -K $i gro on tso on gso off sg on l2-fwd-offload off
>>> tx-nocache-copy on ntuple on
>> Here are many setting above.
> Yes mostly NIC defaults besides the ntuple that is on (for testing 
> some nfc drop filters - and trying to test also tc-offload )
>
>> GRO/GSO/TSO for _forwarding_ is actually bad... in my tests, enabling
>> this result in approx 10% slowdown.
> Ok lets give a try :)
> gro off tso off gso off sg on l2-fwd-offload off tx-nocache-copy on 
> ntuple on
> rx-usecs 10
> 1 CPU / 1 RSS QUEUE
>
> 0;1;64;1609344;96537600;1609279;93327104
> 1;1;64;1608320;96514560;1608256;93293812
> 2;1;64;1608000;96487680;1608125;93267770
> 3;1;64;1608320;96522240;1608576;93297524
> 4;1;64;1605888;96387840;1606211;93148986
> 5;1;64;1601472;96072960;1601600;92870644
> 6;1;64;1602624;96180480;1602243;92959674
> 7;1;64;1601728;96107520;1602113;92907764
> 8;1;64;1602176;96122880;1602176;92933806
> 9;1;64;1603904;96253440;1603777;93045208
>
> A little better performance 1.6Mpps
> But wondering if disabling tso will have no performance impact for tcp 
> traffic ...
> Will try to get some pktgen like pktgen-dpdk that can generate also 
> tcp traffic - to compare this.
>
>
>>
>> AFAIK "tx-nocache-copy on" was also determined to be a bad option.
> I set this to on cause i have better performance (a little 10kpps for 
> this test)
> below same test as above  with tx-nocache-copy off
>
> 0;1;64;1591552;95496960;1591230;92313654
> 1;1;64;1596224;95738880;1595842;92555066
> 2;1;64;1595456;95700480;1595201;92521774
> 3;1;64;1595456;95723520;1595072;92528966
> 4;1;64;1595136;95692800;1595457;92503040
> 5;1;64;1594624;95631360;1594496;92473402
> 6;1;64;1596224;95761920;1595778;92551180
> 7;1;64;1595200;95700480;1595331;92521542
> 8;1;64;1595584;95692800;1595457;92521426
> 9;1;64;1594624;95662080;1594048;92469574
>
>
>
>
>>
>> The "ntuple on" AFAIK disables the flow-director in the NIC.  I though
>> this would actually help VLAN traffic, but I guess not.
> yes I enabled this cause was thinking that can help with traffic on vlans
>
> below same test with ntuple off
> so all settings for ixgbe:
> gro off tso off gso off sg on l2-fwd-offload off tx-nocache-copy off 
> ntuple off
> rx-usecs 10
> rx-flow-hash udp4 sdfn
>
> 0;1;64;1611840;96691200;1611905;93460794
> 1;1;64;1610688;96645120;1610818;93427328
> 2;1;64;1610752;96668160;1610497;93442176
> 3;1;64;1610624;96664320;1610817;93427212
> 4;1;64;1610752;96652800;1610623;93412480
> 5;1;64;1610048;96614400;1610112;93404940
> 6;1;64;1611264;96641280;1611390;93427212
> 7;1;64;1611008;96691200;1610942;93468160
> 8;1;64;1610048;96652800;1609984;93408652
> 9;1;64;1611136;96641280;1610690;93434636
>
> Performance is a little better
> and now with tx-nocache-copy on
>
> 0;1;64;1597248;95834880;1597311;92644096
> 1;1;64;1597888;95865600;1597824;92677446
> 2;1;64;1597952;95834880;1597822;92644038
> 3;1;64;1597568;95877120;1597375;92685044
> 4;1;64;1597184;95827200;1597314;92629190
> 5;1;64;1597696;95842560;1597565;92625652
> 6;1;64;1597312;95834880;1597376;92644038
> 7;1;64;1597568;95873280;1597634;92647924
> 8;1;64;1598400;95919360;1598849;92699602
> 9;1;64;1597824;95873280;1598208;92684928
>
>
> That is weird - so enabling tx-nocache-copy with disabled ntuple have 
> bad performance impact - but with enabled ntuple there is no 
> performance impact
>
>
>
>>
>>
>>>           ethtool -N $i rx-flow-hash udp4 sdfn
>> Why do you change the NICs flow-hash?
> whan used 16 cores / 16 rss queues - there was better load 
> distribution over all cores when sdfn rx-flow-hash enabled
>
>>
>>>           done
>>>
>>> ip link set up dev enp216s0f0
>>> ip link set up dev enp216s0f1
>>>
>>> ip a a 10.0.0.1/30 dev enp216s0f0
>>>
>>> ip link add link enp216s0f1 name vlan1000 type vlan id 1000
>>> ip link set up dev vlan1000
>>> ip a a 10.0.0.5/30 dev vlan1000
>>>
>>>
>>> ip route add 172.16.0.0/12 via 10.0.0.6
>>>
>>> ./set_irq_affinity.sh -x 14-27,42-43 enp216s0f0
>>> ./set_irq_affinity.sh -x 14-27,42-43 enp216s0f1
>>> #cat  /sys/devices/system/node/node1/cpulist
>>> #14-27,42-55
>>> #cat  /sys/devices/system/node/node0/cpulist
>>> #0-13,28-41
>> Is this a NUMA system?
> This is 2x CPU 6132 - so have two separate pcie access to the nic - 
> need to check what cpu is assigned to pcie where network card is 
> connected to have network card on local cpu where all irq's are binded
>
>>
>>> #################################################
>>>
>>>
>>> Looks like forwarding performance when using vlans on ixgbe is less 
>>> that
>>> without vlans for about 30-40% (wondering if this is some vlan
>>> offloading problem and ixgbe)
>> I would see this as a problem/bug that enabling VLANs cost this much.
> Yes - was thinking that with tx/rx vlan offloading there will be not 
> much performance impact when vlans used.
>
>>> settings below:
>>>
>>> ethtool -k enp216s0f0
>>> Features for enp216s0f0:
>>> Cannot get device udp-fragmentation-offload settings: Operation not
>>> supported
>>> rx-checksumming: on
>>> tx-checksumming: on
>>>           tx-checksum-ipv4: off [fixed]
>>>           tx-checksum-ip-generic: on
>>>           tx-checksum-ipv6: off [fixed]
>>>           tx-checksum-fcoe-crc: off [fixed]
>>>           tx-checksum-sctp: on
>>> scatter-gather: on
>>>           tx-scatter-gather: on
>>>           tx-scatter-gather-fraglist: off [fixed]
>>> tcp-segmentation-offload: on
>>>           tx-tcp-segmentation: on
>>>           tx-tcp-ecn-segmentation: off [fixed]
>>>           tx-tcp-mangleid-segmentation: on
>>>           tx-tcp6-segmentation: on
>>> udp-fragmentation-offload: off
>>> generic-segmentation-offload: off
>>> generic-receive-offload: on
>>> large-receive-offload: off
>>> rx-vlan-offload: on
>>> tx-vlan-offload: on
>>> ntuple-filters: on
>>> receive-hashing: on
>>> highdma: on [fixed]
>>> rx-vlan-filter: on
>>> vlan-challenged: off [fixed]
>>> tx-lockless: off [fixed]
>>> netns-local: off [fixed]
>>> tx-gso-robust: off [fixed]
>>> tx-fcoe-segmentation: off [fixed]
>>> tx-gre-segmentation: on
>>> tx-gre-csum-segmentation: on
>>> tx-ipxip4-segmentation: on
>>> tx-ipxip6-segmentation: on
>>> tx-udp_tnl-segmentation: on
>>> tx-udp_tnl-csum-segmentation: on
>>> tx-gso-partial: on
>>> tx-sctp-segmentation: off [fixed]
>>> tx-esp-segmentation: off [fixed]
>>> fcoe-mtu: off [fixed]
>>> tx-nocache-copy: on
>>> loopback: off [fixed]
>>> rx-fcs: off [fixed]
>>> rx-all: off
>>> tx-vlan-stag-hw-insert: off [fixed]
>>> rx-vlan-stag-hw-parse: off [fixed]
>>> rx-vlan-stag-filter: off [fixed]
>>> l2-fwd-offload: off
>>> hw-tc-offload: off
>>> esp-hw-offload: off [fixed]
>>> esp-tx-csum-hw-offload: off [fixed]
>>> rx-udp_tunnel-port-offload: on
>>>
>>>
>>> Another thing is that forwarding performance does not scale with number
>>> of cores when 7+ cores are reached
>> I've seen problems with using Hyper-Threading CPUs.  Could it be that
>> above 7 CPUs you are starting to use sibling-cores ?
> Turbostats can help here:
> Package Core    CPU     Avg_MHz Busy%   Bzy_MHz TSC_MHz IRQ SMI     
> C1      C2      C1%     C2%     CPU%c1  CPU%c6  CoreTmp PkgTmp  
> PkgWatt RAMWatt PKG_%   RAM_%
> -       -       -       72      2.27    3188    2600    194844 0       
> 64      69282   0.07    97.83   18.38   79.36   -4 54 123.49  16.08   
> 0.00    0.00
> 0       0       0       8       0.74    1028    2600    1513 0       
> 32      1462    1.50    97.99   10.92   88.34   47 51 58.34   5.34    
> 0.00    0.00
> 0       0       28      7       0.67    1015    2600    1255 0       
> 12      1249    0.96    98.61   10.99
> 0       1       1       7       0.68    1019    2600    1260 0       
> 0       1260    0.00    99.54   8.44    90.88   49
> 0       1       29      9       0.71    1208    2600    1252 0       
> 0       1253    0.00    99.48   8.41
> 0       2       2       7       0.67    1019    2600    1261 0       
> 0       1260    0.00    99.54   8.44    90.89   48
> 0       2       30      7       0.67    1017    2600    1255 0       
> 0       1255    0.00    99.55   8.44
> 0       3       3       7       0.68    1019    2600    1260 0       
> 0       1259    0.00    99.53   8.46    90.86   -4
> 0       3       31      7       0.67    1017    2600    1256 0       
> 0       1256    0.00    99.55   8.46
> 0       4       4       7       0.67    1027    2600    1260 0       
> 0       1260    0.00    99.54   8.43    90.90   -4
> 0       4       32      7       0.66    1018    2600    1255 0       
> 0       1255    0.00    99.55   8.44
> 0       5       5       7       0.68    1020    2600    1260 0       
> 0       1257    0.00    99.54   8.44    90.89   50
> 0       5       33      7       0.68    1019    2600    1255 0       
> 0       1255    0.00    99.55   8.43
> 0       6       6       7       0.70    1019    2600    1260 0       
> 0       1259    0.00    99.53   8.43    90.87   -4
> 0       6       34      7       0.70    1019    2600    1255 0       
> 0       1255    0.00    99.54   8.43
> 0       8       7       7       0.68    1019    2600    1262 0       
> 0       1261    0.00    99.52   8.42    90.90   50
> 0       8       35      7       0.67    1019    2600    1255 0       
> 0       1255    0.00    99.55   8.43
> 0       9       8       7       0.68    1019    2600    1260 0       
> 0       1257    0.00    99.54   8.40    90.92   49
> 0       9       36      7       0.66    1017    2600    1255 0       
> 0       1255    0.00    99.55   8.41
> 0       10      9       7       0.66    1018    2600    1257 0       
> 0       1257    0.00    99.54   8.40    90.94   -4
> 0       10      37      7       0.66    1018    2600    1255 0       
> 0       1255    0.00    99.55   8.41
> 0       11      10      7       0.66    1019    2600    1257 0       
> 0       1259    0.00    99.54   8.56    90.77   -4
> 0       11      38      7       0.66    1018    2600    1255 0       
> 3       1252    0.19    99.36   8.57
> 0       12      11      7       0.67    1019    2600    1260 0       
> 0       1260    0.00    99.54   8.44    90.88   -4
> 0       12      39      7       0.67    1019    2600    1255 0       
> 0       1256    0.00    99.55   8.44
> 0       13      12      7       0.68    1019    2600    1257 0       
> 4       1254    0.32    99.22   8.67    90.65   -4
> 0       13      40      7       0.69    1019    2600    1256 0       
> 4       1253    0.24    99.31   8.66
> 0       14      13      7       0.71    1020    2600    1260 0       
> 0       1259    0.00    99.53   8.41    90.88   -4
> 0       14      41      7       0.72    1020    2600    1255 0       
> 0       1255    0.00    99.54   8.40
> 1       0       14      3564    99.19   3594    2600    125472 0       
> 0       0       0.00    0.00    0.81    0.00    54 54 65.15   10.74   
> 0.00    0.00
> 1       0       42      3       0.07    3701    2600    1255 0       
> 0       1255    0.00    99.95   99.93
> 1       1       15      11      0.32    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.37   73.31   42
> 1       1       43      10      0.31    3301    2600    1255 0       
> 0       1255    0.00    99.82   26.38
> 1       2       16      10      0.31    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.37   73.32   39
> 1       2       44      10      0.32    3301    2600    1255 0       
> 0       1255    0.00    99.82   26.36
> 1       3       17      10      0.32    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.40   73.28   39
> 1       3       45      11      0.32    3301    2600    1255 0       
> 0       1255    0.00    99.81   26.40
> 1       4       18      10      0.32    3301    2600    1257 0       
> 0       1257    0.00    99.82   26.40   73.28   40
> 1       4       46      11      0.32    3301    2600    1255 0       
> 0       1255    0.00    99.82   26.40
> 1       5       19      11      0.33    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.40   73.27   39
> 1       5       47      11      0.33    3300    2600    1255 0       
> 0       1255    0.00    99.82   26.40
> 1       6       20      12      0.35    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.38   73.27   42
> 1       6       48      12      0.36    3301    2600    1255 0       
> 0       1255    0.00    99.81   26.37
> 1       8       21      11      0.33    3301    2600    1257 0       
> 0       1257    0.00    99.82   26.37   73.29   42
> 1       8       49      11      0.33    3301    2600    1255 0       
> 0       1255    0.00    99.82   26.38
> 1       9       22      10      0.32    3300    2600    1257 0       
> 0       1257    0.00    99.82   26.35   73.34   41
> 1       9       50      10      0.30    3301    2600    1255 0       
> 0       1255    0.00    99.82   26.36
> 1       10      23      10      0.31    3301    2600    1257 0       
> 0       1257    0.00    99.82   26.37   73.33   41
> 1       10      51      10      0.31    3301    2600    1255 0       
> 0       1255    0.00    99.82   26.36
> 1       11      24      10      0.32    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.62   73.06   41
> 1       11      52      10      0.32    3301    2600    1255 0       
> 4       1251    0.32    99.50   26.62
> 1       12      25      11      0.33    3301    2600    1257 0       
> 0       1257    0.00    99.81   26.39   73.28   41
> 1       12      53      11      0.33    3301    2600    1258 0       
> 0       1254    0.00    99.82   26.38
> 1       13      26      12      0.36    3317    2600    1259 0       
> 0       1258    0.00    99.79   26.41   73.23   39
> 1       13      54      11      0.34    3301    2600    1255 0       
> 0       1254    0.00    99.82   26.42
> 1       14      27      12      0.36    3301    2600    1257 0       
> 5       1251    0.24    99.58   26.54   73.10   41
> 1       14      55      12      0.36    3300    2600    1255 0       
> 0       1254    0.00    99.82   26.54
>
>
> So it looks like in all tests i'm using core+sibling
> But side effect of this is that :
> 33 * 100.0 = 3300.0 MHz max turbo 28 active cores
> 33 * 100.0 = 3300.0 MHz max turbo 24 active cores
> 33 * 100.0 = 3300.0 MHz max turbo 20 active cores
> 33 * 100.0 = 3300.0 MHz max turbo 14 active cores
> 34 * 100.0 = 3400.0 MHz max turbo 12 active cores
> 34 * 100.0 = 3400.0 MHz max turbo 8 active cores
> 35 * 100.0 = 3500.0 MHz max turbo 4 active cores
> 37 * 100.0 = 3700.0 MHz max turbo 2 active cores
>
> So more cores = less MHz per core/sibling
>
>>
>>> perf top:
>>>
>>>    PerfTop:   77835 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz
>>> cycles],  (all, 56 CPUs)
>>> --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
>>>
>>>
>>>       16.32%  [kernel]       [k] skb_dst_force
>>>       16.30%  [kernel]       [k] dst_release
>>>       15.11%  [kernel]       [k] rt_cache_valid
>>>       12.62%  [kernel]       [k] ipv4_mtu
>> It seems a little strange that these 4 functions are on the top
> Yes dono why there is ipv4_mtu called and taking soo much cycles
>
>>
>>>        5.60%  [kernel]       [k] do_raw_spin_lock
>> Why is calling/taking this lock? (Use perf call-graph recording).
> can be hard to paste it here:)
> attached file
>
>>
>>>        3.03%  [kernel]       [k] fib_table_lookup
>>>        2.70%  [kernel]       [k] ip_finish_output2
>>>        2.10%  [kernel]       [k] dev_gro_receive
>>>        1.89%  [kernel]       [k] eth_type_trans
>>>        1.81%  [kernel]       [k] ixgbe_poll
>>>        1.15%  [kernel]       [k] ixgbe_xmit_frame_ring
>>>        1.06%  [kernel]       [k] __build_skb
>>>        1.04%  [kernel]       [k] __dev_queue_xmit
>>>        0.97%  [kernel]       [k] ip_rcv
>>>        0.78%  [kernel]       [k] netif_skb_features
>>>        0.74%  [kernel]       [k] ipt_do_table
>> Unloading netfilter modules, will give more performance, but it
>> semifake to do so.
> Compiled in kernel - only in filter mode - with ipv4+ipv6 - no other 
> modules conntrack or other .
>>>        0.70%  [kernel]       [k] acpi_processor_ffh_cstate_enter
>>>        0.64%  [kernel]       [k] ip_forward
>>>        0.59%  [kernel]       [k] __netif_receive_skb_core
>>>        0.55%  [kernel]       [k] dev_hard_start_xmit
>>>        0.53%  [kernel]       [k] ip_route_input_rcu
>>>        0.53%  [kernel]       [k] ip_rcv_finish
>>>        0.51%  [kernel]       [k] page_frag_free
>>>        0.50%  [kernel]       [k] kmem_cache_alloc
>>>        0.50%  [kernel]       [k] udp_v4_early_demux
>>>        0.44%  [kernel]       [k] skb_release_data
>>>        0.42%  [kernel]       [k] inet_gro_receive
>>>        0.40%  [kernel]       [k] sch_direct_xmit
>>>        0.39%  [kernel]       [k] __local_bh_enable_ip
>>>        0.33%  [kernel]       [k] netdev_pick_tx
>>>        0.33%  [kernel]       [k] validate_xmit_skb
>>>        0.28%  [kernel]       [k] fib_validate_source
>>>        0.27%  [kernel]       [k] deliver_ptype_list_skb
>>>        0.25%  [kernel]       [k] eth_header
>>>        0.23%  [kernel]       [k] get_dma_ops
>>>        0.22%  [kernel]       [k] skb_network_protocol
>>>        0.21%  [kernel]       [k] ip_output
>>>        0.21%  [kernel]       [k] vlan_dev_hard_start_xmit
>>>        0.20%  [kernel]       [k] ixgbe_alloc_rx_buffers
>>>        0.18%  [kernel]       [k] nf_hook_slow
>>>        0.18%  [kernel]       [k] apic_timer_interrupt
>>>        0.18%  [kernel]       [k] virt_to_head_page
>>>        0.18%  [kernel]       [k] build_skb
>>>        0.16%  [kernel]       [k] swiotlb_map_page
>>>        0.16%  [kernel]       [k] ip_finish_output
>>>        0.16%  [kernel]       [k] udp4_gro_receive
>>>
>>>
>>> RESULTS:
>>>
>>> CSV format - delimeter ";"
>>>
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;1;64;1470912;88247040;1470720;85305530
>>> 1;1;64;1470912;88285440;1470977;85335110
>>> 2;1;64;1470464;88247040;1470402;85290508
>>> 3;1;64;1471424;88262400;1471230;85353728
>>> 4;1;64;1468736;88166400;1468672;85201652
>>> 5;1;64;1470016;88181760;1469949;85234944
>>> 6;1;64;1470720;88247040;1470466;85290624
>>> 7;1;64;1471232;88277760;1471167;85346246
>>> 8;1;64;1469184;88170240;1469249;85216326
>>> 9;1;64;1470592;88227840;1470847;85294394
>> Single core 1.47Mpps seems a little low, I would expect 2Mpps.
>>
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;2;64;2413120;144802560;2413245;139975924
>>> 1;2;64;2415296;144913920;2415356;140098188
>>> 2;2;64;2416768;144898560;2416573;140105670
>>> 3;2;64;2418176;145056000;2418110;140261806
>>> 4;2;64;2416512;144990720;2416509;140172950
>>> 5;2;64;2415168;144860160;2414466;140064780
>>> 6;2;64;2416960;144983040;2416833;140190930
>>> 7;2;64;2413632;144768000;2413568;140001734
>>> 8;2;64;2415296;144898560;2414589;140087168
>>> 9;2;64;2416576;144963840;2416892;140190930
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;3;64;3419008;205155840;3418882;198239244
>>> 1;3;64;3428032;205585920;3427971;198744234
>>> 2;3;64;3425472;205536000;3425344;198677260
>>> 3;3;64;3425088;205470720;3425156;198603136
>>> 4;3;64;3427648;205693440;3426883;198773888
>>> 5;3;64;3426880;205670400;3427392;198796044
>>> 6;3;64;3429120;205678080;3430140;198848186
>>> 7;3;64;3422976;205355520;3423490;198458136
>>> 8;3;64;3423168;205336320;3423486;198495372
>>> 9;3;64;3424384;205493760;3425538;198617868
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;4;64;4406464;264364800;4405244;255560296
>>> 1;4;64;4404672;264349440;4405122;255541504
>>> 2;4;64;4402368;264049920;4403326;255188864
>>> 3;4;64;4401344;264076800;4400702;255207134
>>> 4;4;64;4385536;263074560;4386620;254312716
>>> 5;4;64;4386560;263189760;4385404;254379532
>>> 6;4;64;4398784;263857920;4399031;255025288
>>> 7;4;64;4407232;264445440;4407998;255637900
>>> 8;4;64;4413184;264698880;4413758;255875816
>>> 9;4;64;4411328;264526080;4411906;255712372
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;5;64;5094464;305871360;5094464;295657262
>>> 1;5;64;5090816;305514240;5091201;295274810
>>> 2;5;64;5088384;305387520;5089792;295175108
>>> 3;5;64;5079296;304869120;5079484;294680368
>>> 4;5;64;5092992;305544960;5094207;295349166
>>> 5;5;64;5092416;305502720;5093372;295334260
>>> 6;5;64;5080896;304896000;5081090;294677004
>>> 7;5;64;5085376;305114880;5086401;294933058
>>> 8;5;64;5092544;305575680;5092036;295356938
>>> 9;5;64;5093056;305652480;5093832;295449506
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;6;64;5705088;342351360;5705784;330965110
>>> 1;6;64;5710272;342743040;5707591;331373952
>>> 2;6;64;5703424;342182400;5701826;330776552
>>> 3;6;64;5708736;342604800;5707963;331147462
>>> 4;6;64;5710144;342654720;5712067;331202910
>>> 5;6;64;5712064;342777600;5711361;331292288
>>> 6;6;64;5710144;342585600;5708607;331144272
>>> 7;6;64;5699840;342021120;5697853;330609222
>>> 8;6;64;5701184;342124800;5702909;330653592
>>> 9;6;64;5711360;342735360;5713283;331247686
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;7;64;6244416;374603520;6243591;362180072
>>> 1;7;64;6230912;374016000;6231490;361534126
>>> 2;7;64;6244800;374776320;6244866;362224326
>>> 3;7;64;6238720;374376960;6238261;361838510
>>> 4;7;64;6218816;373079040;6220413;360683962
>>> 5;7;64;6224320;373566720;6225086;361017404
>>> 6;7;64;6224000;373570560;6221370;360936088
>>> 7;7;64;6210048;372741120;6210627;360212654
>>> 8;7;64;6231616;374035200;6231537;361445502
>>> 9;7;64;6227840;373724160;6228802;361162752
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;8;64;6251840;375144960;6251849;362609678
>>> 1;8;64;6250816;375014400;6250881;362547038
>>> 2;8;64;6257728;375432960;6257160;362911104
>>> 3;8;64;6255552;375325440;6255622;362822074
>>> 4;8;64;6243776;374576640;6243270;362120622
>>> 5;8;64;6237184;374296320;6237690;361790080
>>> 6;8;64;6240960;374415360;6240714;361927366
>>> 7;8;64;6222784;373317120;6223746;360854424
>>> 8;8;64;6225920;373593600;6227014;361154980
>>> 9;8;64;6238528;374304000;6237701;361845238
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;14;64;6486144;389184000;6486135;376236488
>>> 1;14;64;6454912;387390720;6454222;374466734
>>> 2;14;64;6441152;386480640;6440431;373572780
>>> 3;14;64;6450240;386972160;6450870;374070014
>>> 4;14;64;6465600;387997440;6467221;375089654
>>> 5;14;64;6448384;386860800;6448000;373980230
>>> 6;14;64;6452352;387095040;6452148;374168904
>>> 7;14;64;6441984;386507520;6443203;373665058
>>> 8;14;64;6456704;387340800;6455744;374429092
>>> 9;14;64;6464640;387901440;6465218;374949004
>>> ID;CPU_CORES / RSS QUEUES;PKT_SIZE;PPS_RX;BPS_RX;PPS_TX;BPS_TX
>>> 0;16;64;6939008;416325120;6938696;402411192
>>> 1;16;64;6941952;416444160;6941745;402558918
>>> 2;16;64;6960576;417584640;6960707;403698718
>>> 3;16;64;6940736;416486400;6941820;402503876
>>> 4;16;64;6927680;415741440;6927420;401853870
>>> 5;16;64;6929792;415687680;6929917;401839196
>>> 6;16;64;6950400;416989440;6950661;403026166
>>> 7;16;64;6953664;417216000;6953454;403260544
>>> 8;16;64;6948480;416851200;6948800;403023266
>>> 9;16;64;6924160;415422720;6924092;401542468
>> I've seen Linux scale beyond 6.9Mpps, thus I also see this as an
>> issue/bug.  You could be stalling on DMA TX completion being too slow,
>> but you already increased the interval and increased the TX ring queue
>> size.  You could play with those setting and see if it changes this?
>>
>> Could you try my napi_monitor tool in:
>> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/samples/bpf
>>
>> Also provide the output from:
>>   mpstat -P ALL -u -I SCPU -I SUM 2
> with 16 cores / 16 RSS queues
> Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft 
> %steal  %guest  %gnice   %idle
> Average:     all    0.00    0.00    0.01    0.00    0.00   28.57 
> 0.00    0.00    0.00   71.42
> Average:       0    0.00    0.00    0.04    0.00    0.00    0.08 
> 0.00    0.00    0.00   99.88
> Average:       1    0.00    0.00    0.12    0.00    0.00    0.00 
> 0.00    0.00    0.00   99.88
> Average:       2    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       3    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       4    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       5    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       6    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       7    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       8    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:       9    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      10    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      11    0.08    0.00    0.04    0.00    0.00    0.00 
> 0.00    0.00    0.00   99.88
> Average:      12    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      13    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      14    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      15    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      16    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      17    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      18    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      19    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      20    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      21    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      22    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      23    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      24    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      25    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      26    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      27    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      28    0.00    0.00    0.04    0.00    0.00    0.00 
> 0.00    0.00    0.00   99.96
> Average:      29    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      30    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      31    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      32    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      33    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      34    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      35    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      36    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      37    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      38    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      39    0.04    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00   99.96
> Average:      40    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      41    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      42    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      43    0.00    0.00    0.00    0.00    0.00  100.00 
> 0.00    0.00    0.00    0.00
> Average:      44    0.00    0.00    0.04    0.17    0.00    0.00 
> 0.00    0.00    0.00   99.79
> Average:      45    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      46    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      47    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      48    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      49    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      50    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      51    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      52    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      53    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      54    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
> Average:      55    0.00    0.00    0.00    0.00    0.00    0.00 
> 0.00    0.00    0.00  100.00
>
> Average:     CPU    intr/s
> Average:     all 123596.08
> Average:       0    646.38
> Average:       1    500.54
> Average:       2    511.67
> Average:       3    534.25
> Average:       4    542.21
> Average:       5    531.54
> Average:       6    554.58
> Average:       7    535.88
> Average:       8    544.58
> Average:       9    536.42
> Average:      10    575.46
> Average:      11    601.12
> Average:      12    502.08
> Average:      13    575.46
> Average:      14   5917.92
> Average:      15   5949.58
> Average:      16   7021.29
> Average:      17   7299.71
> Average:      18   7391.67
> Average:      19   7354.25
> Average:      20   7543.42
> Average:      21   7354.25
> Average:      22   7322.33
> Average:      23   7368.71
> Average:      24   7429.00
> Average:      25   7406.46
> Average:      26   7400.67
> Average:      27   7447.21
> Average:      28    517.00
> Average:      29    549.54
> Average:      30    529.33
> Average:      31    533.83
> Average:      32    541.25
> Average:      33    541.17
> Average:      34    532.50
> Average:      35    545.17
> Average:      36    528.96
> Average:      37    509.92
> Average:      38    520.12
> Average:      39    523.29
> Average:      40    530.75
> Average:      41    542.33
> Average:      42   5921.71
> Average:      43   5949.42
> Average:      44    503.04
> Average:      45    542.75
> Average:      46    582.50
> Average:      47    581.71
> Average:      48    495.29
> Average:      49    524.38
> Average:      50    527.92
> Average:      51    528.12
> Average:      52    456.38
> Average:      53    477.00
> Average:      54    440.92
> Average:      55    568.83
>
> Average:     CPU       HI/s    TIMER/s   NET_TX/s   NET_RX/s BLOCK/s 
> IRQ_POLL/s  TASKLET/s    SCHED/s  HRTIMER/s      RCU/s
> Average:       0       0.00     250.00       0.17      87.00 
> 0.00       0.00      45.46     250.00       0.00      13.75
> Average:       1       0.00     233.42       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      17.21
> Average:       2       0.00     249.04       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      12.67
> Average:       3       0.00     249.92       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      34.42
> Average:       4       0.00     248.67       0.17       0.00 
> 0.00       0.00       0.00     249.96       0.00      43.42
> Average:       5       0.00     249.46       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      32.17
> Average:       6       0.00     249.79       0.00       0.00 
> 0.00       0.00       0.00     249.87       0.00      54.92
> Average:       7       0.00     240.12       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      45.79
> Average:       8       0.00     247.42       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      47.25
> Average:       9       0.00     249.29       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      37.17
> Average:      10       0.00     248.75       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      76.79
> Average:      11       0.00     249.29       0.00       0.00 
> 0.00       0.00      42.79     249.83       0.00      59.21
> Average:      12       0.00     249.83       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00       2.29
> Average:      13       0.00     249.92       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      75.62
> Average:      14       0.00     148.21       0.17    5758.04 
> 0.00       0.00       0.00       8.42       0.00       3.08
> Average:      15       0.00     148.42       0.46    5789.25 
> 0.00       0.00       0.00       8.33       0.00       3.12
> Average:      16       0.00     142.62       0.79    6866.46 
> 0.00       0.00       0.00       8.29       0.00       3.12
> Average:      17       0.00     143.17       0.42    7145.00 
> 0.00       0.00       0.00       8.08       0.00       3.04
> Average:      18       0.00     153.62       0.42    7226.42 
> 0.00       0.00       0.00       8.04       0.00       3.17
> Average:      19       0.00     150.46       0.46    7192.21 
> 0.00       0.00       0.00       8.04       0.00       3.08
> Average:      20       0.00     145.21       0.17    7386.50 
> 0.00       0.00       0.00       8.29       0.00       3.25
> Average:      21       0.00     150.96       0.46    7191.37 
> 0.00       0.00       0.00       8.25       0.00       3.21
> Average:      22       0.00     146.67       0.54    7163.96 
> 0.00       0.00       0.00       8.04       0.00       3.12
> Average:      23       0.00     151.38       0.42    7205.75 
> 0.00       0.00       0.00       8.00       0.00       3.17
> Average:      24       0.00     153.33       0.17    7264.12 
> 0.00       0.00       0.00       8.08       0.00       3.29
> Average:      25       0.00     153.21       0.17    7241.83 
> 0.00       0.00       0.00       7.96       0.00       3.29
> Average:      26       0.00     153.96       0.17    7234.88 
> 0.00       0.00       0.00       8.38       0.00       3.29
> Average:      27       0.00     151.71       0.79    7283.25 
> 0.00       0.00       0.00       8.04       0.00       3.42
> Average:      28       0.00     245.71       0.00       0.00 
> 0.00       0.00       0.00     249.50       0.00      21.79
> Average:      29       0.00     233.21       0.00       0.00 
> 0.00       0.00       0.00     249.87       0.00      66.46
> Average:      30       0.00     248.92       0.00       0.00 
> 0.00       0.00       0.00     250.00       0.00      30.42
> Average:      31       0.00     249.92       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      33.96
> Average:      32       0.00     248.67       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      42.62
> Average:      33       0.00     249.46       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      41.79
> Average:      34       0.00     249.79       0.00       0.00 
> 0.00       0.00       0.00     249.87       0.00      32.83
> Average:      35       0.00     240.12       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      55.08
> Average:      36       0.00     247.42       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      31.58
> Average:      37       0.00     249.29       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      10.71
> Average:      38       0.00     248.75       0.00       0.00 
> 0.00       0.00       0.00     249.87       0.00      21.50
> Average:      39       0.00     249.50       0.00       0.00 
> 0.00       0.00       0.00     249.83       0.00      23.96
> Average:      40       0.00     249.83       0.00       0.00 
> 0.00       0.00       0.00     249.96       0.00      30.96
> Average:      41       0.00     249.92       0.00       0.00 
> 0.00       0.00       0.00     249.92       0.00      42.50
> Average:      42       0.00     148.38       0.71    5761.00 
> 0.00       0.00       0.00       8.25       0.00       3.38
> Average:      43       0.00     147.21       0.50    5790.33 
> 0.00       0.00       0.00       8.00       0.00       3.38
> Average:      44       0.00     248.96       0.00       0.00 
> 0.00       0.00       0.00     248.13       0.00       5.96
> Average:      45       0.00     249.04       0.00       0.00 
> 0.00       0.00       0.00     248.88       0.00      44.83
> Average:      46       0.00     248.96       0.00       0.00 
> 0.00       0.00       0.00     248.58       0.00      84.96
> Average:      47       0.00     249.00       0.00       0.00 
> 0.00       0.00       0.00     248.75       0.00      83.96
> Average:      48       0.00     249.12       0.00       0.00 
> 0.00       0.00       0.00     132.83       0.00     113.33
> Average:      49       0.00     249.12       0.00       0.00 
> 0.00       0.00       0.00     248.62       0.00      26.62
> Average:      50       0.00     248.92       0.00       0.00 
> 0.00       0.00       0.00     248.58       0.00      30.42
> Average:      51       0.00     249.08       0.00       0.00 
> 0.00       0.00       0.00     248.42       0.00      30.63
> Average:      52       0.00     249.21       0.00       0.00 
> 0.00       0.00       0.00     131.96       0.00      75.21
> Average:      53       0.00     249.08       0.00       0.00 
> 0.00       0.00       0.00     136.12       0.00      91.79
> Average:      54       0.00     249.00       0.00       0.00 
> 0.00       0.00       0.00     136.79       0.00      55.12
> Average:      55       0.00     249.04       0.00       0.00 
> 0.00       0.00       0.00     248.71       0.00      71.08
>
>
>
