From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [BUG] ethX misnumbered and one missing in mii-tool
Date: Thu, 29 Mar 2007 21:21:42 -0700
Message-ID: <4807377b0703292121o6eef3bf2l998878cfd677d821@mail.gmail.com>
References: <1175203383.6219.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"NetDEV list" <netdev@vger.kernel.org>
To: andrei.popa@i-neo.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:10294 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945937AbXC3EVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 00:21:45 -0400
Received: by wr-out-0506.google.com with SMTP id 76so489184wra
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 21:21:43 -0700 (PDT)
In-Reply-To: <1175203383.6219.8.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

added netdev.

On 3/29/07, Andrei Popa <andrei.popa@i-neo.ro> wrote:
> In a dual core 2 server with an intel motherboard and 5 network
> cards(two onboard) and 1 pci express card with two slots and one pci-x
> pci64 card the kernel sees all of them in dmesg but in mii-tool are
> misnumbered and one card is missing.
> (please CC as I am not subscribed to lkml)

please don't use mii-tool, ethtool is a much better option and
actually works with gigabit cards.

> from dmesg:
> Intel(R) PRO/1000 Network Driver - version 7.0.33-k2-NAPI
> Copyright (c) 1999-2005 Intel Corporation.
> ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> PCI: Setting latency timer of device 0000:03:00.0 to 64
> e1000: 0000:03:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:21:0c:08
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection

eth0...

> ACPI: PCI Interrupt 0000:03:00.1[B] -> GSI 17 (level, low) -> IRQ 17
> PCI: Setting latency timer of device 0000:03:00.1 to 64
> e1000: 0000:03:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:21:0c:09
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
eth0...

> ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 18 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:05:00.0 to 64
> e1000: 0000:05:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:17:b7:68
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
eth0...
> GSI 20 sharing vector 0xC9 and IRQ 20
> ACPI: PCI Interrupt 0000:05:00.1[B] -> GSI 19 (level, low) -> IRQ 20
> PCI: Setting latency timer of device 0000:05:00.1 to 64
> e1000: 0000:05:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> 00:15:17:17:b7:69
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
eth0...

> GSI 21 sharing vector 0xD1 and IRQ 21
> ACPI: PCI Interrupt 0000:06:02.0[A] -> GSI 27 (level, low) -> IRQ 21
> e1000: 0000:06:02.0: e1000_probe: (PCI-X:100MHz:64-bit)
> 00:0e:0c:ba:a8:50
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
eth0...

um, I'm a little confused why every interface was named eth0 when it
tried to come up.
you didn't mention what kernel you're using.

you can enable MSI and not share interrupts on this platform, it will
at least help your PCIe adapters.

> zeus ~ # mii-tool
> eth2: no link
> eth5: negotiated 100baseTx-FD, link ok
> eth6: no link
> eth7: no link
> zeus ~ #
>
> it sees only 4 cards that are misnumbered and one is missing.

what does 'ip link' or 'ifconfig -a' show?

Jesse
