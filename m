From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 2 Aug 2017 19:31:19 +0200
Message-ID: <f1554ee7-2151-1304-c5c1-35264b9be5be@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> <yw1xshhagexd.fsf@mansr.com>
 <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr> <yw1xo9rygdyu.fsf@mansr.com>
 <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr> <yw1xk22mgdcx.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:29020 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752804AbdHBRbe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 13:31:34 -0400
In-Reply-To: <yw1xk22mgdcx.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 18:10, Måns Rullgård wrote:

> ping -f is limited to 100 packets per second.
> Use something like iperf in UDP mode instead.

CLIENT: DESKTOP
# iperf3 -c 172.27.64.45 -u -b 950M
Connecting to host 172.27.64.45, port 5201
[  4] local 172.27.64.1 port 55533 connected to 172.27.64.45 port 5201
[ ID] Interval           Transfer     Bandwidth       Total Datagrams
[  4]   0.00-1.00   sec   102 MBytes   858 Mbits/sec  13091  
[  4]   1.00-2.00   sec   114 MBytes   953 Mbits/sec  14541  
[  4]   2.00-3.00   sec   114 MBytes   953 Mbits/sec  14542  
[  4]   3.00-4.00   sec   114 MBytes   953 Mbits/sec  14541  
[  4]   4.00-5.00   sec   114 MBytes   953 Mbits/sec  14542  
[  4]   5.00-6.00   sec   114 MBytes   953 Mbits/sec  14541  
[  4]   6.00-7.00   sec   114 MBytes   953 Mbits/sec  14535  
[  4]   7.00-8.00   sec   114 MBytes   953 Mbits/sec  14536  
[  4]   8.00-9.00   sec   114 MBytes   953 Mbits/sec  14543  
[  4]   9.00-10.00  sec   114 MBytes   953 Mbits/sec  14541  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-10.00  sec  1.10 GBytes   943 Mbits/sec  0.247 ms  132176/143788 (92%)  
[  4] Sent 143788 datagrams

iperf Done.


SERVER: TANGO BOARD
# iperf3 -s
Accepted connection from 172.27.64.1, port 44995
[  5] local 172.27.64.45 port 5201 connected to 172.27.64.1 port 55533
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-1.00   sec  7.90 MBytes  66.2 Mbits/sec  0.218 ms  11365/12376 (92%)  
[  5]   1.00-2.00   sec  9.13 MBytes  76.6 Mbits/sec  0.230 ms  13381/14550 (92%)  
[  5]   2.00-3.00   sec  9.12 MBytes  76.5 Mbits/sec  0.290 ms  13372/14540 (92%)  
[  5]   3.00-4.00   sec  9.11 MBytes  76.4 Mbits/sec  0.292 ms  13369/14535 (92%)  
[  5]   4.00-5.00   sec  9.18 MBytes  77.0 Mbits/sec  0.178 ms  13374/14549 (92%)  
[  5]   5.00-6.00   sec  9.10 MBytes  76.3 Mbits/sec  0.228 ms  13367/14532 (92%)  
[  5]   6.00-7.00   sec  9.26 MBytes  77.7 Mbits/sec  0.607 ms  13356/14541 (92%)  
[  5]   7.00-8.00   sec  9.23 MBytes  77.4 Mbits/sec  0.507 ms  13364/14545 (92%)  
[  5]   8.00-9.00   sec  9.20 MBytes  77.1 Mbits/sec  0.215 ms  13351/14528 (92%)  
[  5]   9.00-10.00  sec  9.16 MBytes  76.9 Mbits/sec  0.188 ms  13356/14529 (92%)  
[  5]  10.00-10.04  sec   336 KBytes  72.2 Mbits/sec  0.247 ms  521/563 (93%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-10.04  sec  0.00 Bytes  0.00 bits/sec  0.247 ms  132176/143788 (92%)  


There is some packet loss, but the board doesn't lose connectivity.

With smaller packets...

# iperf3 -c 172.27.64.45 -u -b 950M -l 800
Connecting to host 172.27.64.45, port 5201
[  4] local 172.27.64.1 port 35197 connected to 172.27.64.45 port 5201
[ ID] Interval           Transfer     Bandwidth       Total Datagrams
[  4]   0.00-1.00   sec  90.6 MBytes   760 Mbits/sec  118724  
[  4]   1.00-2.00   sec   107 MBytes   894 Mbits/sec  139718  
[  4]   2.00-3.00   sec   106 MBytes   889 Mbits/sec  138918  
[  4]   3.00-4.00   sec   107 MBytes   895 Mbits/sec  139768  
[  4]   4.00-5.00   sec   106 MBytes   891 Mbits/sec  139275  
[  4]   5.00-6.00   sec   107 MBytes   895 Mbits/sec  139862  
[  4]   6.00-7.00   sec   107 MBytes   895 Mbits/sec  139825  
[  4]   7.00-8.00   sec   107 MBytes   895 Mbits/sec  139775  
[  4]   8.00-9.00   sec   107 MBytes   895 Mbits/sec  139849  
[  4]   9.00-10.00  sec   107 MBytes   895 Mbits/sec  139835  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-10.00  sec  1.02 GBytes   880 Mbits/sec  0.009 ms  564117/1375520 (41%)  
[  4] Sent 1375520 datagrams

iperf Done.


Accepted connection from 172.27.64.1, port 46151
[  5] local 172.27.64.45 port 5201 connected to 172.27.64.1 port 35197
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-1.00   sec  60.8 MBytes   510 Mbits/sec  0.004 ms  33508/113252 (30%)  
iperf3: OUT OF ORDER - incoming packet = 147146 and received packet = 0 AND SP = 147497
iperf3: OUT OF ORDER - incoming packet = 146128 and received packet = 0 AND SP = 147690
iperf3: OUT OF ORDER - incoming packet = 146067 and received packet = 0 AND SP = 147863
iperf3: OUT OF ORDER - incoming packet = 147242 and received packet = 0 AND SP = 148039
iperf3: OUT OF ORDER - incoming packet = 163837 and received packet = 0 AND SP = 164363
[  5]   1.00-2.00   sec  61.0 MBytes   511 Mbits/sec  0.198 ms  59635/139649 (43%)  
iperf3: OUT OF ORDER - incoming packet = 286437 and received packet = 0 AND SP = 287226
iperf3: OUT OF ORDER - incoming packet = 302990 and received packet = 0 AND SP = 305710
[  5]   2.00-3.00   sec  61.5 MBytes   517 Mbits/sec  0.005 ms  58369/138944 (42%)  
iperf3: OUT OF ORDER - incoming packet = 427697 and received packet = 0 AND SP = 428089
iperf3: OUT OF ORDER - incoming packet = 441087 and received packet = 0 AND SP = 442963
iperf3: OUT OF ORDER - incoming packet = 453844 and received packet = 0 AND SP = 454238
[  5]   3.00-4.00   sec  61.7 MBytes   517 Mbits/sec  0.008 ms  58975/139795 (42%)  
[  5]   4.00-5.00   sec  61.3 MBytes   514 Mbits/sec  0.010 ms  58453/138795 (42%)  
[  5]   5.00-6.00   sec  61.2 MBytes   513 Mbits/sec  0.014 ms  60141/140338 (43%)  
[  5]   6.00-7.00   sec  61.3 MBytes   514 Mbits/sec  0.009 ms  59055/139384 (42%)  
iperf3: OUT OF ORDER - incoming packet = 993646 and received packet = 0 AND SP = 994370
[  5]   7.00-8.00   sec  61.0 MBytes   512 Mbits/sec  0.007 ms  60265/140210 (43%)  
iperf3: OUT OF ORDER - incoming packet = 1134516 and received packet = 0 AND SP = 1135942
[  5]   8.00-9.00   sec  62.6 MBytes   523 Mbits/sec  0.198 ms  57805/139795 (41%)  
iperf3: OUT OF ORDER - incoming packet = 1275612 and received packet = 0 AND SP = 1277716
[  5]   9.00-10.00  sec  64.0 MBytes   538 Mbits/sec  0.007 ms  56029/139888 (40%)  
[  5]  10.00-10.04  sec  2.74 MBytes   589 Mbits/sec  0.009 ms  1882/5470 (34%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-10.04  sec  0.00 Bytes  0.00 bits/sec  0.009 ms  564117/1375520 (41%)  
[SUM]  0.0-10.0 sec  13 datagrams received out-of-order


A lot more packet loss, but RX holds on.

Regards.
