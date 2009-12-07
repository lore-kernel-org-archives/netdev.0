From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14748] New: e1000e NIC not working after
 reboot
Date: Mon, 7 Dec 2009 13:50:28 -0800
Message-ID: <20091207135028.0c33a4f4.akpm@linux-foundation.org>
References: <bug-14748-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, macieks@freesco.pl
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38990 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965055AbZLGVuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 16:50:46 -0500
In-Reply-To: <bug-14748-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 6 Dec 2009 13:04:20 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14748
> 
>            Summary: e1000e NIC not working after reboot
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: macieks@freesco.pl
>         Regression: Yes
> 
> 
> When I power up my system the NIC is working properly.
> After every reboot the NIC is not working. I mean the eth0 is created, but
> neither dhcpcd gets IP nor static setup helps
> .
> ifconfig eth0 shows zero packets on Rx and Tx (no errors, overrunns, etc.)
> 
> logs after modprobing e1000e (NIC working OK):
> Dec  6 12:29:28 mcxR kernel: e1000e: Intel(R) PRO/1000 Network Driver -
> 1.0.2-k2
> Dec  6 12:29:28 mcxR kernel: e1000e: Copyright (c) 1999-2008 Intel Corporation.
> Dec  6 12:29:28 mcxR kernel: e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level,
> low) -> IRQ 20
> Dec  6 12:29:28 mcxR kernel: e1000e 0000:00:19.0: setting latency timer to 64
> Dec  6 12:29:28 mcxR kernel: e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> Dec  6 12:29:28 mcxR kernel: 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1)
> 00:15:58:cc:0f:35
> Dec  6 12:29:28 mcxR kernel: 0000:00:19.0: eth0: Intel(R) PRO/1000 Network
> Connection
> Dec  6 12:29:28 mcxR kernel: 0000:00:19.0: eth0: MAC: 6, PHY: 6, PBA No:
> ffffff-0ff
> Dec  6 12:29:28 mcxR kernel: e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> Dec  6 12:29:28 mcxR kernel: e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> Dec  6 12:29:30 mcxR kernel: e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex,
> Flow Control: RX/TX
> 
> 
> logs after rebooting system and modprobing e1000e (NIC not working):
> Dec  6 11:57:46 mcxR kernel: e1000e: Intel(R) PRO/1000 Network Driver -
> 1.0.2-k2
> Dec  6 11:57:46 mcxR kernel: e1000e: Copyright (c) 1999-2008 Intel Corporation.
> Dec  6 11:57:46 mcxR kernel: e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level,
> low) -> IRQ 20
> Dec  6 11:57:46 mcxR kernel: e1000e 0000:00:19.0: setting latency timer to 64
> Dec  6 11:57:46 mcxR kernel: e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> Dec  6 11:57:46 mcxR kernel: 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1)
> 00:15:58:cc:0f:35
> Dec  6 11:57:46 mcxR kernel: 0000:00:19.0: eth0: Intel(R) PRO/1000 Network
> Connection
> Dec  6 11:57:46 mcxR kernel: 0000:00:19.0: eth0: MAC: 6, PHY: 6, PBA No:
> ffffff-0ff
> Dec  6 11:57:48 mcxR kernel: e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> Dec  6 11:57:48 mcxR kernel: e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> 
> 
> Additional info:
> Software:
>  - distro: Arch Linux
>  - kernel version: 2.6.32
>  - e1000e version: 1.0.2-k2  
> 
> 
> Hardware:
>  - notebook: Lenovo ThinkPad R61
>  - network card: Intel Gigabit
> 
> # lspci -v
> 00:19.0 Ethernet controller: Intel Corporation 82566MC Gigabit Network
> Connection (rev 03)
>         Subsystem: Lenovo Device 20ba
>         Flags: bus master, fast devsel, latency 0, IRQ 11
>         Memory at fe200000 (32-bit, non-prefetchable) [size=128K]
>         Memory at fe224000 (32-bit, non-prefetchable) [size=4K]
>         I/O ports at 1800 [size=32]
>         Capabilities: [c8] Power Management version 2
>         Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>         Kernel modules: e1000e
> 
> $ uname -a
> Linux mcxR 2.6.32-ARCH #7 SMP PREEMPT Fri Dec 4 15:39:16 CET 2009 x86_64
> Intel(R) Core(TM)2 Duo CPU T7100 @ 1.80GHz GenuineIntel GNU/Linux
> 

Thanks.  You don't mention which previous kernel version worked OK. 
Was it 2.6.31?

