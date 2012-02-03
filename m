From: Andy Hawkins <adhawkins@gmail.com>
Subject: Realtek 8169 based device
Date: Fri, 3 Feb 2012 10:17:06 +0000
Message-ID: <CAOkhdCf-emWHJ0rB9GtC3MnX6oj3jgRAbYJU+q65GzMUdXmd-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:65018 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab2BCKRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 05:17:07 -0500
Received: by dadp15 with SMTP id p15so2618112dad.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 02:17:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Firstly, apologies if this is the wrong place to ask this. Please let
me know if somewhere else is more appropriate.

Secondly, I realise that the kernel I'm using here is quite old.
However, this is the kernel provided by the version of Openfiler I'm
using, so updating isn't a simple matter.

I've just installed a Zyxel GN680T NIC into a PC (purchased here:
http://www.dabs.com/products/zyxel-gn680t-gigabit-pci-network-card-75Q5.html).
Initially it wasn't recognised by the device.

lspci -vv reports:


03:01.0 Ethernet controller: Hynix Semiconductor Unknown device 8169 (rev 10)
        Subsystem: Hynix Semiconductor Unknown device 8169
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR+
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at de00 [size=256]
        Region 1: [virtual] Memory at fdaff000 (32-bit,
non-prefetchable) [size=256]
        [virtual] Expansion ROM at fd900000 [disabled] [size=128K]
        Capabilities: [5c] #00 [0000]

lspci -n reports:


03:01.0 0200: 106c:8169 (rev 10)

I had a look at the driver source, and it didn't appear to be
correctly recognising the PCI IDs. I managed to recompile the module,
adding in support for this device as follows:


        { PCI_DEVICE(0x106c,    0x8169), 0, 0, RTL_CFG_0 },

When I load this new module, the device is correctly recognised, and
ethtool can give sensible information and report negotiated link
speeds etc. However the network card fails to work (I'm pretty sure it
was reporting transmit time outs).

Can anyone offer any advice on getting this card to work?

Thanks

Andy
