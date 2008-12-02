From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Tue, 2 Dec 2008 23:55:33 +0100
Message-ID: <20081202225533.GA28767@1wt.eu>
References: <20081120184310.GB27712@xw6200.broadcom.net> <20081120212637.GB23844@1wt.eu> <20081120215318.GB27907@xw6200.broadcom.net> <20081124132744.GB24851@1wt.eu> <20081124215247.GA29696@1wt.eu> <20081125015223.GA9151@xw6200.broadcom.net> <20081125053128.GA32426@1wt.eu> <20081125175413.GA9808@xw6200.broadcom.net> <20081126211220.GA22374@1wt.eu> <20081126225421.GA8906@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1455 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbYLBWzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 17:55:43 -0500
Content-Disposition: inline
In-Reply-To: <20081126225421.GA8906@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

I ran a lot of tests last night. I have a few more information.
The issue sometimes takes longer to reproduce so it caused me
to identify wrong culprits among the 29 patches affecting tg3
between 2.6.25 and 2.6.27.7. I was finally able to reproduce
the issue by running the plain 2.6.25 driver (v3.90) on 2.6.27.7,
but not at all when running on 2.6.25, even after ten minutes
(in 2.6.27.7, it takes between 5s and 1mn to get a tx timeout).

Later, I noticed that 2.6.27's driver uses libphy, which was
never removed between tests. I wonder if it can interfer with
my tests. Maybe it initializes the phy differently from plain
2.6.25, causing delayed issues, I don't know. Unfortunately,
I cannot run 2.6.27's driver on 2.6.25 because of the libphy
dependency (that's how I discovered it).

I'm also now 100% certain that enabling/disabling FC does not
change anything with either kernel. So unless the hardware still
interpretes pause frames when disabled, it should not come from
there.

I suspect that the switch is getting ill : The problem happens
more often when it's been transfering at full speed for some
time. Since it's a cheap one lying on a desk, it might have
burned out capacitors in it causing some randomly corrupt
frames to go out from time to time (maybe even pause frames
preventing the NIC from sending). That was also a problem
for my tests, because after patching/unpatching and compilation
phases, it had some time to rest and took longer to reproduce
the issue.

I will re-run some tests on 2.6.27 + tg3 v3.90 (from 2.6.25)
without ever loading libphy from the power up, in order to
clearly identify if the problem is caused by the driver or
something else in the kernel. If it's something else, the
bisect will take a few weeks since I'm not there long enough
to run about 15 full builds and wait long enough for the
problem to (not) occur.

But I'm keeping hope, there's no reason not to find it!

Regards,
Willy

