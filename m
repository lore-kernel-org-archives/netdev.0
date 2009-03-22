From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
	resetting -> dead NIC
Date: Sun, 22 Mar 2009 14:21:21 +0100
Message-ID: <20090322132121.GA7871@pest>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de> <20090319165842.GA10819@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.73]:58738 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752893AbZCVNVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 09:21:33 -0400
Content-Disposition: inline
In-Reply-To: <20090319165842.GA10819@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 09:58:42AM -0700, Matt Carlson wrote:

Hello Matt,

> Hi Bernhard.  I talked to Michael about this and we'd like you to try
> two things.
> 
> 1) Can you disable iLo2 and see if you can still reproduce the problem?
> 2) Can you apply the following patch to get more information on when
>    MMIO gets disabled?

Not sure this is going to help you. NIC crashed two times tonight, logs
look like this

Mar 22 04:06:46 svr02 kernel: [1392136.468921] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:47 svr02 kernel: [1392137.520288] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:48 svr02 kernel: [1392138.568267] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:49 svr02 kernel: [1392139.616266] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:50 svr02 kernel: [1392140.664266] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:51 svr02 kernel: [1392141.712276] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:52 svr02 kernel: [1392142.760297] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:53 svr02 kernel: [1392143.808258] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:54 svr02 kernel: [1392144.856256] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:55 svr02 kernel: [1392145.904266] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:56 svr02 kernel: [1392146.952276] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:57 svr02 kernel: [1392148.000267] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:58 svr02 kernel: [1392149.048271] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:06:59 svr02 kernel: [1392150.096268] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:00 svr02 kernel: [1392151.144277] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:01 svr02 kernel: [1392152.192287] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:02 svr02 kernel: [1392153.240268] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:03 svr02 kernel: [1392154.288267] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:04 svr02 kernel: [1392155.336267] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:05 svr02 kernel: [1392156.384268] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:07 svr02 kernel: [1392157.432267] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:08 svr02 kernel: [1392158.480266] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:09 svr02 kernel: [1392159.528289] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:10 svr02 kernel: [1392160.576297] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:11 svr02 kernel: [1392161.624277] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:12 svr02 kernel: [1392162.672267] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:13 svr02 kernel: [1392163.720266] PCI Memory Mapped IO Disabled!!!!
Mar 22 04:07:14 svr02 kernel: [1392164.768266] PCI Memory Mapped IO Disabled!!!!

at this point the "watchdog" kicked in and did rmmod/modprobe, so I
think the only thing you can read out of this debugging log is that
there was no kernel message right before MMIO got disabled and it takes
quite a while to fire the Tx timeout.

Mar 22 04:07:15 svr02 kernel: [1392165.540078] tg3 0000:03:04.1: PCI INT B disabled
Mar 22 04:07:16 svr02 kernel: [1392166.817125] tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff
Mar 22 04:07:18 svr02 kernel: [1392168.398844] tg3: eth0: No firmware running.
Mar 22 04:07:29 svr02 kernel: [1392179.793309] tg3: eth0: Link is down.
Mar 22 04:07:31 svr02 kernel: [1392181.896030] tg3 0000:03:04.0: PCI INT A disabled
Mar 22 04:07:33 svr02 kernel: [1392183.957132] tg3.c:v3.94 (August 14, 2008)
Mar 22 04:07:33 svr02 kernel: [1392184.020034] tg3 0000:03:04.0: enabling device (0000 -> 0002)
Mar 22 04:07:33 svr02 kernel: [1392184.086083] tg3 0000:03:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16

I'm now switching to eth1.

Bernhard
