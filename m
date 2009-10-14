From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: tcpdump versus atomic?
Date: Wed, 14 Oct 2009 00:23:07 -0400
Message-ID: <4AD5522B.50101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:48636 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbZJNEXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 00:23:47 -0400
Received: by yxe26 with SMTP id 26so5034405yxe.4
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 21:23:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anybody know what code path tcpdump changes to running atomic?

Is there a function to test whether you're running atomic?

Dutifully testing, and noticed a strange anomaly.  When the code is
running normally, no problems.  When running tcpdump on the client, no
problems.  When running tcpdump on the server:

[   88.997594] device eth0 entered promiscuous mode
[  114.827403] BUG: scheduling while atomic: swapper/0/0x10000100
[  114.827462] Modules linked in: lp snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd ppdev iTCO_wdt iTCO_vendor_support psmouse soundcore parport_pc intel_agp parport agpgart pcspkr serio_raw shpchp snd_page_alloc 8139too aic7xxx 8139cp 
scsi_transport_spi mii floppy
[  114.827493]
[  114.827497] Pid: 0, comm: swapper Not tainted (2.6.32-rc3 #4) Imperial
[  114.827501] EIP: 0060:[<c0123295>] EFLAGS: 00000246 CPU: 0
[  114.827512] EIP is at native_safe_halt+0x5/0x10
[  114.827515] EAX: c0740000 EBX: 00000000 ECX: ffff4b6e EDX: 00000000
[  114.827519] ESI: c07992c0 EDI: c0743000 EBP: c0741fa0 ESP: c0741fa0
[  114.827522]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  114.827525] CR0: 8005003b CR2: 09278fc4 CR3: 04b56000 CR4: 00000690
[  114.827529] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  114.827532] DR6: ffff0ff0 DR7: 00000400
[  114.827535] Call Trace:
[  114.827546]  [<c01098b5>] default_idle+0x65/0x90
[  114.827550]  [<c0102062>] cpu_idle+0x52/0x90
[  114.827558]  [<c056cc23>] rest_init+0x53/0x60
[  114.827565]  [<c079c93d>] start_kernel+0x328/0x390
[  114.827569]  [<c079c3ce>] ? unknown_bootoption+0x0/0x1f6
[  114.827574]  [<c079c07e>] i386_start_kernel+0x7e/0xa8
[  136.570632] device eth0 left promiscuous mode

