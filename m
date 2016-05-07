From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtk8168 driver help needed
Date: Sat, 7 May 2016 10:35:11 +0200
Message-ID: <20160507083511.GA18421@electric-eye.fr.zoreil.com>
References: <572D147C.8020203@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41181 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbcEGIfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 04:35:16 -0400
Content-Disposition: inline
In-Reply-To: <572D147C.8020203@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Murali Karicheri <m-karicheri2@ti.com> :
[...]
> I am trying to integrate the rtl8168 PCIe card to have Ethernet functional
> on my Keystone EVM.

Which (EVM) one ?

> I purchased the rtl8111c Gib card from Amazon. The Card is detected
> by the RC and I can see it is enumerated and show up when doing lspci command.

What does "the RC" mean ? A different PC ?

> However I can't get the Ethernet port functional.

> Does this need MSI interrupt ?

No.

> I can't see it has requested any.

Yes, something went really, really wrong. See below.

[...]
> [    2.303965] PCI host bridge /soc/pcie@21800000 ranges:
> [    2.309108]   No bus range found for /soc/pcie@21800000, using [bus 00-ff]
> [    2.316269]    IO 0x23250000..0x23253fff -> 0x00000000
> [    2.321499]   MEM 0x50000000..0x5fffffff -> 0x50000000
> [    2.331666] keystone-pcie 21801000.pcie: PCI host bridge to bus 0000:00
> [    2.338283] pci_bus 0000:00: root bus resource [bus 00-ff]
> [    2.343937] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
> [    2.350114] pci_bus 0000:00: root bus resource [mem 0x50000000-0x5fffffff]
> [    2.357095] pci 0000:00:00.0: [104c:b00b] type 01 class 0x060400
> [    2.357665] PCI: bus0: Fast back to back transfers disabled
> [    2.363717] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
> [    2.363809] pci 0000:01:00.0: reg 0x10: [io  0x0000-0x00ff]
> [    2.363867] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x00000fff 64bit]
> [    2.363909] pci 0000:01:00.0: reg 0x20: [mem 0x00000000-0x0000ffff 64bit pref]
> [    2.363939] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
> [    2.364099] pci 0000:01:00.0: supports D1 D2
> [    2.364116] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    2.381251] PCI: bus1: Fast back to back transfers disabled
> [    2.386989] pci 0000:00:00.0: BAR 8: assigned [mem 0x50000000-0x500fffff]
> [    2.393937] pci 0000:00:00.0: BAR 9: assigned [mem 0x50100000-0x501fffff pref]
> [    2.401221] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
> [    2.407320] pci 0000:01:00.0: BAR 6: assigned [mem 0x50100000-0x5011ffff pref]
> [    2.414597] pci 0000:01:00.0: BAR 4: assigned [mem 0x50120000-0x5012ffff 64bit pref]
> [    2.422380] pci 0000:01:00.0: BAR 2: assigned [mem 0x50000000-0x50000fff 64bit]
> [    2.429702] pci 0000:01:00.0: BAR 0: assigned [io  0x1000-0x10ff]
> [    2.435821] pci 0000:00:00.0: PCI bridge to [bus 01]
> [    2.440783] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
> [    2.446896] pci 0000:00:00.0:   bridge window [mem 0x50000000-0x500fffff]
> [    2.453699] pci 0000:00:00.0:   bridge window [mem 0x50100000-0x501fffff pref]
> [    2.461453] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
> [    2.468411] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
> [    2.475075] pcie_pme 0000:00:00.0:pcie01: service driver pcie_pme loaded
> [    2.475392] aer 0000:00:00.0:pcie02: service driver aer loaded
> [    2.475652] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    2.481419] r8169 0000:01:00.0: enabling device (0140 -> 0143)
> [    2.488865] r8169 0000:01:00.0 eth0: RTL8169 at 0xf0d6a000, 00:00:00:00:00:00, XID 00000000 IRQ 286

No need to go further, there is a serious problem here.

Most of the XID bits are read from a mapped register. They're definitely not
expected to be null as the driver requires it to identify a proper chipset
(the common PCI configuration registers only tell that you aren't dealing
with a coffee machine).

Any read returning zeroes would not surprize me.

[...]
> Can someone help me figure out what is missing ?

Hardly at this point. I can only suggest to switch power off, plug
the 8168 device in a x86 (32 or 64 bits) system and check how it behaves.

-- 
Ueimor
