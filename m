From: "John P Poet" <jppoet@gmail.com>
Subject: Realtek 8111C transmit timed out
Date: Mon, 4 Aug 2008 19:12:30 -0600
Message-ID: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:6237 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbYHEBMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 21:12:32 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1150869fgg.17
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 18:12:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I recently bought a new motherboard with Realtek 8111C nics.  The nic
is detected as:

dmesg:
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:06:00.0[A] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:06:00.0 to 64
eth0: RTL8168c/8111c at 0xffffc2000063e000, 00:1f:d0:20:01:57, XID
3c4000c0 IRQ 2292

lspci -v:
06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
        Subsystem: Giga-byte Technology Unknown device e000
        Flags: bus master, fast devsel, latency 0, IRQ 2292
        I/O ports at b000 [size=256]
        Memory at de010000 (64-bit, prefetchable) [size=4K]
        Memory at de000000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at de020000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
        Capabilities: [70] Express Endpoint, MSI 01
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
        Capabilities: [d0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Capabilities: [160] Device Serial Number 78-56-34-12-78-56-34-12
        Kernel driver in use: r8169
        Kernel modules: r8169

I have been having two problems with this nic:

1) On a cold boot, the nic is not brought up correctly.  It seems to
stay at 100mbit instead of going into gbit mode, and it fails to ping
the router even though it seems to get a valid IP address.  If I then
warm boot the computer, then then nic comes up in gbit just fine, and
generally works.

2) I am getting a lot of timeouts:

Aug  4 17:49:35 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  4 17:49:35 saphire kernel: r8169: eth0: link up
Aug  4 17:50:05 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  4 17:50:05 saphire kernel: r8169: eth0: link up
...
Aug  4 18:52:17 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  4 18:52:17 saphire kernel: r8169: eth0: link up
...
Aug  4 18:55:59 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  4 18:55:59 saphire kernel: r8169: eth0: link up
...
Aug  4 18:57:47 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  4 18:57:47 saphire kernel: r8169: eth0: link up

While the booting problem is annoying, the timeouts are actually even
more so.  I am a mythtv users, and those timeouts cause my video/audio
streaming to fail.

Is there anything I can do about these problems?

Thank you,

John
-- 
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
