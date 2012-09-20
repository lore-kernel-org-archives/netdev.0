From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 10:10:43 -0700
Message-ID: <505B4E13.5000501@hp.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net> <1347901326.26523.149.camel@edumazet-glaptop> <1347901493.26523.151.camel@edumazet-glaptop> <20120917.130732.1894375657044880827.davem@davemloft.net> <1348067659.26523.949.camel@edumazet-glaptop> <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com> <1348119475.31352.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:37184 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab2ITRKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 13:10:47 -0400
In-Reply-To: <1348119475.31352.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 10:37 PM, Eric Dumazet wrote:
> loopback is lossless, so its always surprising we can have TCP
> retransmits on this medium ;)

Is it lossless?

raj@tardy:~/netperf2_trunk$ netstat -s | grep pru
     19 packets pruned from receive queue because of socket buffer overrun

raj@tardy:~/netperf2_trunk$ src/netperf -t TCP_RR -- -b 256 -D -o 
burst_size,local_transport_retrans,remote_transport_retrans
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to localhost.localdomain () port 0 AF_INET : nodelay : histogram : demo 
: first burst 256
Initial Burst Requests,Local Transport Retransmissions,Remote Transport 
Retransmissions
256,151,94

raj@tardy:~/netperf2_trunk$ netstat -s | grep pru    26 packets pruned 
from receive queue because of socket buffer overrun
raj@tardy:~/netperf2_trunk$ uname -a
Linux tardy 2.6.38-16-generic #67-Ubuntu SMP Thu Sep 6 17:58:38 UTC 2012 
x86_64 x86_64 x86_64 GNU/Linux

Admittedly, my test is on an older kernel, but have things changed in 
this regard since then?   I had to get a bit more contrived on a later 
kernel in a VM (vs what is running directly on my workstation):

raj@tardy-ubuntu-1204:~$ netstat -s | grep -e prune -e retrans    1 
segments retransmited
     4 packets pruned from receive queue because of socket buffer overrun
     1 fast retransmits
raj@tardy-ubuntu-1204:~$ netperf -t TCP_RR -- -b 1024 -D -S 16K -o 
local_transport_retrans,remote_transport_retrans
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to localhost () port 0 AF_INET : nodelay : demo : first burst 1024
Local Transport Retransmissions,Remote Transport Retransmissions
1,0
raj@tardy-ubuntu-1204:~$ netstat -s | grep -e prune -e retrans    2 
segments retransmited
     7 packets pruned from receive queue because of socket buffer overrun
     2 fast retransmits
raj@tardy-ubuntu-1204:~$ uname -a
Linux tardy-ubuntu-1204 3.6.0-rc3+ #7 SMP Mon Sep 10 14:46:05 PDT 2012 
x86_64 x86_64 x86_64 GNU/Linux

rick
