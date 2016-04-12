From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP reaching to maximum throughput after a long time
Date: Tue, 12 Apr 2016 07:52:44 -0700
Message-ID: <1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
References: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	open list <linux-kernel@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: "Machani, Yaniv" <yanivma@ti.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35034 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932606AbcDLOwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 10:52:47 -0400
In-Reply-To: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-12 at 12:17 +0000, Machani, Yaniv wrote:
> Hi,
> After updating from Kernel 3.14 to Kernel 4.4 we have seen a TCP performance degradation over Wi-Fi.
> In 3.14 kernel, TCP got to its max throughout after less than a second, while in the 4.4  it is taking ~20-30 seconds.
> UDP TX/RX and TCP RX performance is as expected.
> We are using a Beagle Bone Black and a WiLink8 device.
> 
> Were there any related changes that might cause such behavior ?
> Kernel configuration and sysctl values were compared, but no significant differences have been found.
> 
> See a log of the behavior below :
> -----------------------------------------------------------
> Client connecting to 10.2.46.5, TCP port 5001
> TCP window size:  320 KByte (WARNING: requested  256 KByte)
> ------------------------------------------------------------
> [  3] local 10.2.46.6 port 49282 connected with 10.2.46.5 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0- 1.0 sec  5.75 MBytes  48.2 Mbits/sec
> [  3]  1.0- 2.0 sec  6.50 MBytes  54.5 Mbits/sec
> [  3]  2.0- 3.0 sec  6.50 MBytes  54.5 Mbits/sec
> [  3]  3.0- 4.0 sec  6.50 MBytes  54.5 Mbits/sec
> [  3]  4.0- 5.0 sec  6.75 MBytes  56.6 Mbits/sec
> [  3]  5.0- 6.0 sec  3.38 MBytes  28.3 Mbits/sec
> [  3]  6.0- 7.0 sec  6.38 MBytes  53.5 Mbits/sec
> [  3]  7.0- 8.0 sec  6.88 MBytes  57.7 Mbits/sec
> [  3]  8.0- 9.0 sec  7.12 MBytes  59.8 Mbits/sec
> [  3]  9.0-10.0 sec  7.12 MBytes  59.8 Mbits/sec
> [  3] 10.0-11.0 sec  7.12 MBytes  59.8 Mbits/sec
> [  3] 11.0-12.0 sec  7.25 MBytes  60.8 Mbits/sec
> [  3] 12.0-13.0 sec  7.12 MBytes  59.8 Mbits/sec
> [  3] 13.0-14.0 sec  7.25 MBytes  60.8 Mbits/sec
> [  3] 14.0-15.0 sec  7.62 MBytes  64.0 Mbits/sec
> [  3] 15.0-16.0 sec  7.88 MBytes  66.1 Mbits/sec
> [  3] 16.0-17.0 sec  8.12 MBytes  68.2 Mbits/sec
> [  3] 17.0-18.0 sec  8.25 MBytes  69.2 Mbits/sec
> [  3] 18.0-19.0 sec  8.50 MBytes  71.3 Mbits/sec
> [  3] 19.0-20.0 sec  8.88 MBytes  74.4 Mbits/sec
> [  3] 20.0-21.0 sec  8.75 MBytes  73.4 Mbits/sec
> [  3] 21.0-22.0 sec  8.62 MBytes  72.4 Mbits/sec
> [  3] 22.0-23.0 sec  8.75 MBytes  73.4 Mbits/sec
> [  3] 23.0-24.0 sec  8.50 MBytes  71.3 Mbits/sec
> [  3] 24.0-25.0 sec  8.62 MBytes  72.4 Mbits/sec
> [  3] 25.0-26.0 sec  8.62 MBytes  72.4 Mbits/sec
> [  3] 26.0-27.0 sec  8.62 MBytes  72.4 Mbits/sec
> 

CC netdev, where this is better discussed.

This could be a lot of different factors, and caused by a sender
problem, a receiver problem, ...

TCP behavior depends on the drivers, so maybe a change there can explain
this.

You could capture the first 5000 frames of the flow and post the pcap ?
(-s 128 to capture only the headers)

tcpdump -p -s 128 -i eth0 -c 5000 host 10.2.46.5 -w flow.pcap

 
Also, while test is running, you could fetch 
ss -temoi dst 10.2.46.5:5001
