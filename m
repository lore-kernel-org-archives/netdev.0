From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 18:40:45 +0200
Message-ID: <200905231840.45483.mb@bu3sch.de>
References: <200903041828.49972.m.bueker@berlin.de> <200905231644.13326.mb@bu3sch.de> <4A180FD0.5050101@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?iso-8859-1?q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:55322 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656AbZEWQlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 12:41:52 -0400
In-Reply-To: <4A180FD0.5050101@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 May 2009 17:01:36 Michael Riepe wrote:
> The client, since I wanted to measure write throughput. The server is a
> Lenovo Thinkpad T60 (e1000e driver).
> 
> > I'm running the iperf server on the r8169 and get the following results:
> > 
> > mb@homer:~$ iperf -c 192.168.2.50 -t120 -i10
> 
> In that case, the r8169 is receiving data (which never was a problem, at
> least for me - it only lost interrupts in TX mode).

Ok, I tested the other way around and it shows the problem:

mb@quimby:~/kernel$ iperf -c 192.168.2.205 -t120 -i10
------------------------------------------------------------
Client connecting to 192.168.2.205, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.2.50 port 34788 connected with 192.168.2.205 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec    501 MBytes    420 Mbits/sec
[  3] 10.0-20.0 sec    533 MBytes    447 Mbits/sec
[  3] 20.0-30.0 sec    699 MBytes    587 Mbits/sec
[  3] 30.0-40.0 sec    715 MBytes    600 Mbits/sec
[  3] 40.0-50.0 sec    469 MBytes    394 Mbits/sec
[  3] 50.0-60.0 sec    466 MBytes    391 Mbits/sec
[  3] 60.0-70.0 sec    464 MBytes    389 Mbits/sec
[  3] 70.0-80.0 sec    498 MBytes    418 Mbits/sec
[  3] 80.0-90.0 sec    477 MBytes    400 Mbits/sec
[  3] 90.0-100.0 sec    601 MBytes    504 Mbits/sec
[  3] 100.0-110.0 sec    696 MBytes    584 Mbits/sec
[  3] 110.0-120.0 sec    510 MBytes    428 Mbits/sec
[  3]  0.0-120.0 sec  6.47 GBytes    463 Mbits/sec


-- 
Greetings, Michael.
