From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Thu, 3 Aug 2017 10:34:31 +0200
Message-ID: <c1aeaa45-de6a-e643-8765-7dad58a8b038@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> <yw1xshhagexd.fsf@mansr.com>
 <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr> <yw1xo9rygdyu.fsf@mansr.com>
 <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr> <yw1xk22mgdcx.fsf@mansr.com>
 <f1554ee7-2151-1304-c5c1-35264b9be5be@free.fr>
 <71dd7987-8c43-2548-5058-51a95658da71@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:35178 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbdHCIep (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 04:34:45 -0400
In-Reply-To: <71dd7987-8c43-2548-5058-51a95658da71@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 22:02, Mason wrote:

> I need to run the test slightly slower, to prevent packet loss
> at the sender.

# iperf3 -c 172.27.64.45 -u -b 0 -l 1000
Connecting to host 172.27.64.45, port 5201
[  4] local 172.27.64.1 port 42607 connected to 172.27.64.45 port 5201
[ ID] Interval           Transfer     Bandwidth       Total Datagrams
[  4]   0.00-1.00   sec   111 MBytes   931 Mbits/sec  116420  
[  4]   1.00-2.00   sec   111 MBytes   931 Mbits/sec  116390  
[  4]   2.00-3.00   sec   111 MBytes   930 Mbits/sec  116220  
[  4]   3.00-4.00   sec   111 MBytes   930 Mbits/sec  116310  
[  4]   4.00-5.00   sec   111 MBytes   931 Mbits/sec  116380  
[  4]   5.00-6.00   sec   111 MBytes   930 Mbits/sec  116280  
[  4]   6.00-7.00   sec   111 MBytes   931 Mbits/sec  116390  
[  4]   7.00-8.00   sec   111 MBytes   931 Mbits/sec  116370  
[  4]   8.00-9.00   sec   111 MBytes   931 Mbits/sec  116340  
[  4]   9.00-10.00  sec   111 MBytes   930 Mbits/sec  116310  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  4]   0.00-10.00  sec  1.08 GBytes   931 Mbits/sec  0.009 ms  278644/1163363 (24%)  
[  4] Sent 1163363 datagrams

iperf Done.


# iperf3 -s
Accepted connection from 172.27.64.1, port 42966
[  5] local 172.27.64.45 port 5201 connected to 172.27.64.1 port 42607
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-1.00   sec  81.1 MBytes   681 Mbits/sec  0.017 ms  26834/111909 (24%)  
[  5]   1.00-2.00   sec  84.2 MBytes   706 Mbits/sec  0.019 ms  28127/116384 (24%)  
[  5]   2.00-3.00   sec  84.2 MBytes   706 Mbits/sec  0.013 ms  27946/116204 (24%)  
[  5]   3.00-4.00   sec  84.5 MBytes   709 Mbits/sec  0.013 ms  27674/116311 (24%)  
[  5]   4.00-5.00   sec  84.6 MBytes   709 Mbits/sec  0.015 ms  27712/116387 (24%)  
[  5]   5.00-6.00   sec  84.5 MBytes   709 Mbits/sec  0.010 ms  27649/116265 (24%)  
[  5]   6.00-7.00   sec  84.3 MBytes   707 Mbits/sec  0.011 ms  27995/116382 (24%)  
[  5]   7.00-8.00   sec  84.3 MBytes   707 Mbits/sec  0.013 ms  27972/116387 (24%)  
[  5]   8.00-9.00   sec  84.3 MBytes   708 Mbits/sec  0.020 ms  27899/116343 (24%)  
[  5]   9.00-10.00  sec  84.4 MBytes   708 Mbits/sec  0.014 ms  27759/116305 (24%)  
[  5]  10.00-10.04  sec  3.25 MBytes   710 Mbits/sec  0.009 ms  1077/4486 (24%)  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total Datagrams
[  5]   0.00-10.04  sec  0.00 Bytes  0.00 bits/sec  0.009 ms  278644/1163363 (24%)  


IIUC, sender (desktop system) sends datagrams as fast as possible.
Receiver (tango board) drops around 24% of all datagrams.
I think this invalidates the theory that exhausting RX descriptors
wedges RX DMA.

Regards.
