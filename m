From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG  kernel 2.6.25-rc3  IPV6]  ping6 -I eth0 ff02::1 causes
 system hang.
Date: Mon, 3 Mar 2008 23:40:17 -0800
Message-ID: <20080303234017.60dee072.akpm@linux-foundation.org>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20080302210716.69727582.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Komuro <komurojun-mbn@nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35369 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752699AbYCDHkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:40:52 -0500
In-Reply-To: <20080302210716.69727582.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Mar 2008 21:07:16 +0900 Komuro <komurojun-mbn@nifty.com> wrote:

> Hi,
> 
> On kernel 2.6.25-rc3, IPV6 multicast ping causes system hang
> after sending several multicast ping packet.
> 
> >ping6 -I eth0 ff02::1 
> 
> This problem does not happen on kernel 2.6.24.
> (does not depend on NIC)
> 

Let's cc the netdev list..

I tried it with 2.6.25-rc3-mm1 and got:

t61p:/home/akpm> ping6 -I eth0 ff02::1 
PING ff02::1(ff02::1) from fe80::215:58ff:fec6:dc4b eth0: 56 data bytes
64 bytes from fe80::215:58ff:fec6:dc4b: icmp_seq=1 ttl=64 time=0.059 ms
64 bytes from fe80::219:d1ff:fe04:8f42: icmp_seq=1 ttl=64 time=1.74 ms (DUP!)
64 bytes from fe80::214:51ff:fe67:55ef: icmp_seq=1 ttl=64 time=2.42 ms (DUP!)
64 bytes from fe80::202:b3ff:fe8f:a731: icmp_seq=1 ttl=64 time=4.72 ms (DUP!)
64 bytes from fe80::211:24ff:fe71:cbe4: icmp_seq=1 ttl=64 time=451 ms (DUP!)
64 bytes from fe80::215:58ff:fec6:dc4b: icmp_seq=2 ttl=64 time=0.090 ms
64 bytes from fe80::202:b3ff:fe8f:a731: icmp_seq=2 ttl=64 time=0.499 ms (DUP!)
64 bytes from fe80::214:51ff:fe67:55ef: icmp_seq=2 ttl=64 time=0.542 ms (DUP!)
64 bytes from fe80::219:d1ff:fe04:8f42: icmp_seq=2 ttl=64 time=0.576 ms (DUP!)
64 bytes from fe80::211:24ff:fe71:cbe4: icmp_seq=2 ttl=64 time=0.609 ms (DUP!)
64 bytes from fe80::215:58ff:fec6:dc4b: icmp_seq=3 ttl=64 time=0.086 ms
64 bytes from fe80::202:b3ff:fe8f:a731: icmp_seq=3 ttl=64 time=0.484 ms (DUP!)
64 bytes from fe80::214:51ff:fe67:55ef: icmp_seq=3 ttl=64 time=0.527 ms (DUP!)
64 bytes from fe80::219:d1ff:fe04:8f42: icmp_seq=3 ttl=64 time=0.561 ms (DUP!)
64 bytes from fe80::211:24ff:fe71:cbe4: icmp_seq=3 ttl=64 time=0.595 ms (DUP!)
64 bytes from fe80::215:58ff:fec6:dc4b: icmp_seq=4 ttl=64 time=0.084 ms
64 bytes from fe80::202:b3ff:fe8f:a731: icmp_seq=4 ttl=64 time=0.314 ms (DUP!)
64 bytes from fe80::214:51ff:fe67:55ef: icmp_seq=4 ttl=64 time=0.352 ms (DUP!)
64 bytes from fe80::211:24ff:fe71:cbe4: icmp_seq=4 ttl=64 time=0.386 ms (DUP!)
64 bytes from fe80::219:d1ff:fe04:8f42: icmp_seq=4 ttl=64 time=0.420 ms (DUP!)
64 bytes from fe80::215:58ff:fec6:dc4b: icmp_seq=5 ttl=64 time=0.106 ms
64 bytes from fe80::202:b3ff:fe8f:a731: icmp_seq=5 ttl=64 time=0.551 ms (DUP!)
64 bytes from fe80::214:51ff:fe67:55ef: icmp_seq=5 ttl=64 time=0.593 ms (DUP!)
64 bytes from fe80::219:d1ff:fe04:8f42: icmp_seq=5 ttl=64 time=0.627 ms (DUP!)
64 bytes from fe80::211:24ff:fe71:cbe4: icmp_seq=5 ttl=64 time=0.661 ms (DUP!)
^C
--- ff02::1 ping statistics ---
5 packets transmitted, 5 received, +20 duplicates, 0% packet loss, time 3999ms
rtt min/avg/max/mdev = 0.059/18.754/451.249/88.287 ms


