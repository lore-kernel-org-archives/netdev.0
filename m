From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 10:46:12 -0700
Message-ID: <4FDA2364.9090508@hp.com>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com> <1339665719.22704.692.camel@edumazet-glaptop> <1339667417.22704.707.camel@edumazet-glaptop> <CAL8zT=icffEiz9MeaNwMtzteQnXiaT4k++s0TPWt5zsnHxFbmw@mail.gmail.com> <CAL8zT=huqtqBKzH3DDwid_C8jH16SH=kjYEK6zjxp_spfnLxXA@mail.gmail.com> <1339684157.22704.722.camel@edumazet-glaptop> <CAL8zT=joBA5pgXB7QfDM5qhOizmdneghXsSnwN5G74-yoGzg_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:22843 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449Ab2FNRqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 13:46:14 -0400
In-Reply-To: <CAL8zT=joBA5pgXB7QfDM5qhOizmdneghXsSnwN5G74-yoGzg_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2012 08:43 AM, Jean-Michel Hautbois wrote:
> As suggested by Eric, here is a description I wish to be as precise as possible.
> I send three RAW video frames, 1920x1088@30fps on three udp sockets to
> the same NIC.
> Each sending is in a thread, so I will focus on the numbers for one thread.
>
> This generates burst of send(), as this : each 1/30s send 3.133.440
> bytes to the ethernet interface.
> This is in fact something similar to this :
> while (n != 0)
> {
>    sendto(socket, packet, 4000);
>    n -= 4000;
>    packet += 4000
> }
>
> My interface is a bond with a 10Gbps interface and MTU set to 4096.
> This means I have 784 packets each 1/30s which are sent on my
> interface by one thread, then I wait for the next burst, and so on.
> The videos are not necessarily the same video, so the threads may send
> simultaneously or not...
>
> My socket is in blocking mode.

If desired, here is how to simulate that with netperf:

./configure --enable-intervals
make

And an example over loopback:

raj@tardy:~/netperf2_trunk$ src/netperf -l 10 -t UDP_STREAM -H localhost 
-w 33 -b 783 -- -s 1M -S 1M -m 4000
MIGRATED UDP STREAM TEST from ::0 (::) port 0 AF_INET6 to tardy (::1) 
port 0 AF_INET6 : interval
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

2097152    4000   9.99       260739      0     835.18
2097152           9.99       260442            834.23


Adjust the -s and/or -S options to match what Jean-Michel's application 
uses for socket buffer sizes.  Run another two simultaneous instances to 
get the three streams.  Adjust the run length with the -l option.

happy benchmarking,

rick jones
