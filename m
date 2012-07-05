From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 09:43:12 +0200
Message-ID: <1341474192.2583.3299.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41882 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754404Ab2GEHnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 03:43:16 -0400
Received: by eaak11 with SMTP id k11so3113162eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 00:43:15 -0700 (PDT)
In-Reply-To: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 09:45 +0800, Ming Lei wrote:
> Hi,
> 
> I observed that on both 3.5-rc5 and 3.5-rc5-next, TCP transmit performance
> degrades a lot, see my below simple test:
> 
> 1, test box
> NIC: 100M USB, normally can reach > 90Mbits/sec
> 

What was the last "OK" kernel version ?

What NIC driver is it ?

> 2, run below command on the box:
> [root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
> ------------------------------------------------------------
> Client connecting to 192.168.0.103, TCP port 5001
> TCP window size:   256 KByte (WARNING: requested   128 KByte)
> ------------------------------------------------------------
> [  3] local 192.168.0.108 port 59315 connected with 192.168.0.103 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec  40.4 MBytes  33.9 Mbits/sec
> 
> note: 192.168.0.103 is another production machine running 'iperf -s -w 131072'
> 
> 3, from traffic captured in wireshark, the window size of most of tcp packets
> from the test box to 192.168.0.103 is set as 229, looks very weird and should
> be the cause of performance regression.
> 

Packets sent to 192.168.0.103 announce the window suitable for packets
in the other way, so not relevant to your problem.

Could you do

# tcpdump -i eth0 -s 100 -c 1000 -w tcp.pcap host 192.168.0.103 &
# iperf -c 192.168.0.103 -w 131072 -t 10

and post the tcp.pcap file ?

By the way, if you remove -w 131072 (on both sides), I guess throughput
will increase.
