From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Fri, 8 Sep 2006 11:42:04 +0200
Message-ID: <20060908094204.GB26916@harddisk-recovery.com>
References: <45006221.4090603@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	Michael Buesch <mb@bu3sch.de>, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:4815 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S1750726AbWIHJmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 05:42:07 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <45006221.4090603@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2006 at 01:17:05PM -0500, Larry Finger wrote:
> I think I have a fix for the bcm43xx bug that leads to NETDEV WATCHDOG tx timeouts and would like it
> to get as much testing as possible as this bug affects V2.6.18-rcX. If the problem is truly
> fixed, I hope to get the fix into mainline before release of the bug into the stable series.

FWIW, I finally tracked down the bug that hangs my laptop to the
bcm43xx driver. At first I got the impression it was the cpufreq code
(which has been flaky in early 2.6.18-rc kernels), but after disabling
that my laptop still crashed. After that I disabled preempt cause I got
a couple of lockdep warnings when I had it enabled. That didn't make a
difference, laptop still hangs after some time (runs a couple of hours
at most). Right now I'm on wired network and my laptop finally doesn't
hang anymore (up for two days).

The hang is very hard to trigger (i.e.: it happens at random, I see no
pattern) and locks up the machine completely. I've tried to capture
kernel messages through serial console, but that doesn't work (lock up
before any messages are printed).

This is with any 2.6.18-rc kernel without additional patches or
proprietary modules, 2.6.17 works ok.

Output from lspci:

0000:06:00.0 Network controller: Broadcom Corporation BCM4318 [AirForce
One 54g] 802.11g Wireless LAN Controller (rev 02)
        Subsystem: Linksys WPC54G-EU version 3 [Wireless-G Notebook Adapter]
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at 36000000 (32-bit, non-prefetchable) [size=8K]
00: e4 14 18 43 06 00 00 00 02 00 80 02 00 40 00 00
10: 00 00 00 36 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 37 17 48 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 01 00 00

Is the patch you just posted supposed to fix the kind of problems I
have, or do I have to look elsewhere?


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
