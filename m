From: Ingo Molnar <mingo@elte.hu>
Subject: [bug] forcedeth: hung interface under load
Date: Tue, 3 Apr 2007 09:05:14 +0200
Message-ID: <20070403070514.GA22940@elte.hu>
References: <20070402115325.GA945@elte.hu> <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com> <20070403062629.GA13210@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39083 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416AbXDCHFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 03:05:34 -0400
Content-Disposition: inline
In-Reply-To: <20070403062629.GA13210@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> > I had responded eariler to the thread asking you to try out the patch
> > found in bug 8058:
> > http://bugzilla.kernel.org/show_bug.cgi?id=8058
> > 
> > I believe that is the caush of the NULL skb dereference issue.
> 
> there's a different type of regression now: under high load i dont get 
> a crash, i get a hung interface instead. No error packets or other 
> weird interface state - just a hung interface. [...]

the interface stats do not change from that point on:

eth1      Link encap:Ethernet  HWaddr 00:13:D4:DC:41:12
          inet addr:10.0.1.12  Bcast:10.0.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14976 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3928743 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1028544 (1004.4 KiB)  TX bytes:4126766510 (3.8 GiB)
          Interrupt:16 Base address:0xa000

and the irq count does not change either:

 16:        816    3463148   IO-APIC-fasteoi   eth1

no matter what i do to the interface. So it's completely stuck. 
No kernel messages either - apparently nv_tx_timeout() never triggered.

note, the hang occurs faster if you set max_interrupt_work to a really 
low value (such as 0). [ The hang occurs _much_ faster if you apply the 
-rt patch and enable PREEMPT_RT - but the hang occurs on mainline too. ]

	Ingo
