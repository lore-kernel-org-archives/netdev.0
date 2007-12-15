From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: Regression: Wireshark sees no packets in 2.6.24-rc3
Date: Sat, 15 Dec 2007 03:41:16 +0100
Message-ID: <47633ECC.3020804@googlemail.com>
References: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com> <200712150305.02589.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ray Lee <ray@madrabbit.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:17807 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbXLOClZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 21:41:25 -0500
Received: by fg-out-1718.google.com with SMTP id e21so21281fga.17
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 18:41:24 -0800 (PST)
In-Reply-To: <200712150305.02589.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> On Friday, 14 of December 2007, Ray Lee wrote:
>> tshark -i eth0, eth1, lo are all empty. Works under 2.6.23.0 just
>> fine. A quick scan of the log between 2.6.24-rc3 and current tip
>> (-rc5) doesn't show any obvious fixes, but then again, what do I know.
>> I'll check current tip on the weekend when I'll have the luxury to
>> have my main system down long enough for a test. Right now I'm kinda
>> up against a deadline, but didn't want to leave it unreported. Should
>> be easy for someone else to confirm or deny whether current tip has
>> the problem.
> 
> FYI, I have created a bugzilla entry for this issue at:
> http://bugzilla.kernel.org/show_bug.cgi?id=9568

Hmm what do you mean by empty ? it does not capturing anything on that interface ?

I do run -rc5-git with wireshark-0.99.6 and tshark -i eth0 or lo works here.

snip

...

-- sudo tshark -i eth0

Capturing on eth0
1197685732.785920  192.168.0.1 -> 239.255.255.250 SSDP NOTIFY * HTTP/1.1
1197685732.790126  192.168.0.1 -> 239.255.255.250 SSDP NOTIFY * HTTP/1.1
1197685732.793613  192.168.0.1 -> 239.255.255.250 SSDP NOTIFY * HTTP/1.1
1197685732.797656  192.168.0.1 -> 239.255.255.250 SSDP NOTIFY * HTTP/1.1
...

1197685738.680962  77.37.20.73 -> 192.168.0.2  TCP 44544 > 44625 [PSH, ACK] Seq=0 Ack=20 Win=88 Len=27 TSV=914082460 TSER=145333592
1197685738.681007  192.168.0.2 -> 77.37.20.73  TCP 44625 > 44544 [ACK] Seq=20 Ack=27 Win=1002 Len=0 TSV=145333645 TSER=914082460
1197685745.994576  192.168.0.2 -> 81.169.185.129 NTP NTP client
1197685746.058523 81.169.185.129 -> 192.168.0.2  NTP NTP server
1197685749.058576  192.168.0.2 -> 85.214.68.60 NTP NTP client
1197685749.121771 85.214.68.60 -> 192.168.0.2  NTP NTP server
1197685751.391157  77.37.20.73 -> 192.168.0.2  TCP 44544 > 44625 [PSH, ACK] Seq=27 Ack=20 Win=88 Len=55 TSV=914085637 TSER=145333645
1197685751.391201  192.168.0.2 -> 77.37.20.73  TCP 44625 > 44544 [ACK] Seq=20 Ack=82 Win=1002 Len=0 TSV=145346355 TSER=914085637

....

-- sudo tshark -i lo

Capturing on lo
1197686288.330222  192.168.0.2 -> 192.168.0.2  TCP 53122 > http [SYN] Seq=0 Len=0 MSS=16396 TSV=145883294 TSER=0 WS=6
1197686288.330225  192.168.0.2 -> 192.168.0.2  TCP http > 53122 [SYN, ACK] Seq=0 Ack=1 Win=32768 Len=0 MSS=16396 TSV=145883294 TSER=145883294 WS=6
1197686288.330251  192.168.0.2 -> 192.168.0.2  TCP 53122 > http [ACK] Seq=1 Ack=1 Win=32832 Len=0 TSV=145883294 TSER=145883294
1197686288.330327  192.168.0.2 -> 192.168.0.2  HTTP GET /.KDE/kdegames-3.97.1_747147.tar.bz2 HTTP/1.0
1197686288.330357  192.168.0.2 -> 192.168.0.2  TCP http > 53122 [ACK] Seq=1 Ack=132 Win=33856 Len=0 TSV=145883294 TSER=145883294
1197686288.474624  192.168.0.2 -> 192.168.0.2  HTTP HTTP/1.1 200 OK (application/x-bzip2)
1197686288.474684  192.168.0.2 -> 192.168.0.2  TCP 53122 > http [ACK] Seq=132 Ack=16385 Win=49344 Len=0 TSV=145883439 TSER=145883439

....

snip


Regards,

Gabriel
