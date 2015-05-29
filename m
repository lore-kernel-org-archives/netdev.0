From: Gianluca Anzolin <gianluca@sottospazio.it>
Subject: NIC related spontaneous wakeup
Date: Fri, 29 May 2015 14:51:46 +0200
Message-ID: <20150529125146.GA29725@sottospazio.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m-r2.th.seeweb.it ([5.144.164.171]:58991 "EHLO
	m-r2.th.seeweb.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbbE2M5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 08:57:35 -0400
Received: from fseek.strangled.net (host20-178-dynamic.6-79-r.retail.telecomitalia.it [79.6.178.20])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by m-r2.th.seeweb.it (Postfix) with ESMTPSA id 659B53F287
	for <netdev@vger.kernel.org>; Fri, 29 May 2015 14:51:50 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm experiencing a puzzling issue with my system: whenever I wake up my
PC with a WOL magic packet and then power it off, the system turns on by
itself after a couple of seconds, even if the network cable is
disconnected.

This issue doesn't occur when I turn on the system on with the regular
power button.

I can reproduce this issue 100% of the times, with any kernel,
even with the latest stable kernel (4.0.4 that I'm using right now).

The integrated network card is an Intel 82574L that works with the
e1000e kernel driver.

Here follows the relevant lspci entry:

04:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network
Connection
	Subsystem: ASUSTeK Computer Inc. Motherboard
	Flags: bus master, fast devsel, latency 0, IRQ 17
	Memory at f6400000 (32-bit, non-prefetchable) [size=128K]
	I/O ports at d000 [size=32]
	Memory at f6420000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: e1000e
	Kernel modules: e1000e

Since I can reproduce this problem so easily I took a snapshot of a
lspci -vvvxxx before powering down the system, either when the system
stays off or when it spontaneously wakes up.

Apart from some changes of IRQs and IO ports, the only difference I
found is this:

-               RootSta: PME ReqID 0000, PMEStatus- PMEPending-
+               RootSta: PME ReqID 0400, PMEStatus- PMEPending-

for the following lspci entry:

00:1c.5 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset
Family PCI Express Root Port 6 (rev b5) (prog-if 00 [Normal decode])

The output of lspci -t is as follows:

-[0000:00]-+-00.0
           +-01.0-[01]--+-00.0
           |            \-00.1
           +-06.0-[02]--
           +-16.0
           +-1a.0
           +-1b.0
           +-1c.0-[03]--
           +-1c.5-[04]----00.0
           +-1c.6-[05]----00.0
           +-1c.7-[06]----00.0
           +-1d.0
           +-1e.0-[07]----03.0
           +-1f.0
           +-1f.2
           \-1f.3

So it seems that behind that PCI bridge there is only the NIC, and I'm
back to the start.

Can anybody give me a direction to debug this further or to solve this
issue? I can provide the full lspci output if needed.

I already sent a similar email to the acpi mailing list and they
suggested me to ask here.

Thank you,

Gianluca
