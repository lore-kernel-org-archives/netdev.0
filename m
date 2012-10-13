From: Roland Stigge <stigge@antcom.de>
Subject: Re: r8169 delay / segfault
Date: Sat, 13 Oct 2012 11:59:11 +0200
Message-ID: <50793B6F.50507@antcom.de>
References: <50787109.7080605@antcom.de> <20121012210503.GA2054@electric-eye.fr.zoreil.com> <50789649.3080202@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:49511 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204Ab2JMJ7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2012 05:59:31 -0400
In-Reply-To: <50789649.3080202@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 13/10/12 00:14, Roland Stigge wrote:
>> Can you send the XID line from the r8169 driver ? It should be in the
>> upper part of the dmesg log.
> 
> Oct 12 23:46:45 darwin kernel: [    1.562479] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> Oct 12 23:46:45 darwin kernel: [    1.562728] r8169 0000:02:00.0: irq 40 for MSI/MSI-X
> Oct 12 23:46:45 darwin kernel: [    1.562968] r8169 0000:02:00.0: eth0: RTL8168evl/8111evl at 0xffffc9000066c000, e8:03:9a:dc:e7:57, XID 0c900800 IRQ 40
> Oct 12 23:46:45 darwin kernel: [    1.562972] r8169 0000:02:00.0: eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]

Additional info: After reloading the driver after the failed state, I get:

[ 2454.524089] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[ 2454.537300] r8169 0000:02:00.0: Refused to change power state, currently in D3
[ 2454.537334] r8169 0000:02:00.0: cache line size of 64 is not supported
[ 2454.537342] r8169 0000:02:00.0: (unregistered net_device): Mem-Wr-Inval unavailable
[ 2454.537425] r8169 0000:02:00.0: (unregistered net_device): unknown MAC, using family default
[ 2454.547513] r8169 0000:02:00.0: (unregistered net_device): rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
[ 2454.548092] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc9000066c000, ff:ff:ff:ff:ff:ff, XID 9cf0f8ff IRQ 19
[ 2454.548103] r8169 0000:02:00.0: eth0: jumbo features [frames: 4080 bytes, tx checksumming: ko]

What does the different device ID, XID and IRQ number mean? How can we
force the device out of D3 power state?

I also compared with kernel 3.5, and it seems like a regression to me,
With 3.5, it works and tells on resume:

[   37.643061] Extended CMOS year: 2000
[   37.644466] ACPI: Low-level resume complete
[   37.644516] PM: Restoring platform NVS memory
[   37.644901] Extended CMOS year: 2000
[   37.644944] Enabling non-boot CPUs ...
[   37.645127] Booting Node 0 Processor 1 APIC 0x1
[   37.659483] CPU1 is up
[   37.659662] Booting Node 0 Processor 2 APIC 0x2
[   37.673887] CPU2 is up
[   37.674060] Booting Node 0 Processor 3 APIC 0x3
[   37.688354] CPU3 is up
[   37.693255] ACPI: Waking up from system sleep state S3
[   37.742293] PM: noirq resume of devices complete after 1.725 msecs
[   37.742392] PM: early resume of devices complete after 0.050 msecs
[   37.742421] i915 0000:00:02.0: >setting latency timer to 64
[   37.742445] ehci_hcd 0000:00:1d.0: >setting latency timer to 64
[   37.742484] ata_piix 0000:00:1f.2: >setting latency timer to 64
[   37.742496] snd_hda_intel 0000:00:1b.0: >irq 48 for MSI/MSI-X
[   37.743872] ata_piix 0000:00:1f.5: >setting latency timer to 64
[   37.743887] r8169 0000:02:00.0: >wake-up capability disabled by ACPI
[   37.743972] ata1.00: _GTF evaluation failed (AE 0x1001)
[   37.789378] [drm] Enabling RC6 states: RC6 on, RC6p on, RC6pp off
[   37.825318] r8169 0000:02:00.0: >eth0: link down
[   37.992301] usb 1-1.6: >reset high-speed USB device number 4 using ehci_hcd
[   38.327824] usb 1-1.5: >reset full-speed USB device number 3 using ehci_hcd
[   38.422689] btusb 1-1.5:1.0: >no reset_resume for driver btusb?
[   38.422691] btusb 1-1.5:1.1: >no reset_resume for driver btusb?
[   38.766989] ata2.00: failed to resume link (SControl 30)
[   39.086505] ata1.01: failed to resume link (SControl 0)
[   39.242350] ata1.00: SATA link up 6.0 Gbps (SStatus 133 SControl 330)
[   39.242362] ata1.01: SATA link down (SStatus 0 SControl 0)
[   39.258694] ata1.00: configured for UDMA/133
[   39.258925] sd 0:0:0:0: >[sda] Starting disk
[   39.793487] ata2.01: failed to resume link (SControl 0)
[   39.804987] ata2.00: SATA link down (SStatus 4 SControl 30)
[   39.805001] ata2.01: SATA link down (SStatus 0 SControl 0)
[   39.805211] PM: resume of devices complete after 2065.886 msecs
[   39.805431] PM: Finishing wakeup.
[   39.805432] Restarting tasks ... done.

Thanks in advance,

Roland
