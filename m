From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 17:01:36 +0200
Message-ID: <4A180FD0.5050101@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de> <200905231124.28925.mb@bu3sch.de> <4A1809B0.3030109@googlemail.com> <200905231644.13326.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:41692 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbZEWPBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 11:01:38 -0400
In-Reply-To: <200905231644.13326.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Michael Buesch wrote:
> On Saturday 23 May 2009 16:35:28 Michael Riepe wrote:
> 
>>Hi!
>>
>>Michael Buesch wrote:
>>
>>
>>>Thanks a lot, Dave! This fixes the issue on my chip.
>>
>>Yep, it's stable here as well. And even a little faster than pci=nomsi.
>>The only strangeness I observed is that the throughput (measured with
>>iperf and a single TCP connection) varies:
>>
>>[ ID] Interval       Transfer     Bandwidth
>>[  3]  0.0-10.0 sec    667 MBytes    559 Mbits/sec
>>[  3] 10.0-20.0 sec    803 MBytes    673 Mbits/sec
>>[  3] 20.0-30.0 sec    802 MBytes    673 Mbits/sec
>>[  3] 30.0-40.0 sec    714 MBytes    599 Mbits/sec
>>[  3] 40.0-50.0 sec    669 MBytes    561 Mbits/sec
>>[  3] 50.0-60.0 sec    791 MBytes    663 Mbits/sec
>>[  3]  0.0-60.0 sec  4.34 GBytes    622 Mbits/sec
> 
> 
> Are you running the iperf server or client on the r8169?

The client, since I wanted to measure write throughput. The server is a
Lenovo Thinkpad T60 (e1000e driver).

> I'm running the iperf server on the r8169 and get the following results:
> 
> mb@homer:~$ iperf -c 192.168.2.50 -t120 -i10

In that case, the r8169 is receiving data (which never was a problem, at
least for me - it only lost interrupts in TX mode).

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
