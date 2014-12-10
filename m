From: Nils Holland <nholland@tisys.org>
Subject: tg3 broken in 3.18.0?
Date: Thu, 11 Dec 2014 00:06:34 +0100
Message-ID: <20141210230634.GA22884@teela.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from celine.tisys.org ([85.25.117.166]:46251 "EHLO celine.tisys.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758349AbaLJXOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 18:14:32 -0500
Received: from teela.fritz.box (ip4d14050c.dynamic.kabel-deutschland.de [77.20.5.12])
	by celine.tisys.org (Postfix) with ESMTPSA id B5E975140494
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 00:06:36 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I just upgraded a machine from 3.17.3 to 3.18.0 and noticed that after
the upgrade, the machine's network interface (which is a tg3) would no
longer run correctly (or, for that matter, run at all). During the
upgrade, I didn't change any kernel config options or any other parts
of the system.

Since the machine is remote and I don't have direct access to it, it's
kind of hard currently to give more details, but here's what I'm
seeing in the logs:

[Booting 3.17.3:]
[    1.383151] tg3.c:v3.137 (May 11, 2014)
[    1.387296] libphy: tg3 mdio bus: probed
[    1.452600] tg3 0000:02:00.0 eth0:
        Tigon3 [partno(BCM57780) rev 57780001] (PCI Express) MAC address
        00:19:99:ce:13:a6
[    1.454660] tg3 0000:02:00.0 eth0:
        attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)
[    1.456764] tg3 0000:02:00.0 eth0:
        RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    1.458911] tg3 0000:02:00.0 eth0:
        dma_rwctrl[76180000] dma_mask[64-bit]
[...]
[    6.602608] tg3 0000:02:00.0
        enp2s0: renamed from eth0
[    9.865638] tg3 0000:02:00.0: irq 25 for MSI/MSI-X
[    9.887584] IPv6:
        ADDRCONF(NETDEV_UP): enp2s0: link is not ready
[   10.469819] tg3 0000:02:00.0
        enp2s0: Link is down
[   12.477396] tg3 0000:02:00.0
        enp2s0: Link is up at 100 Mbps, full duplex
[   12.477404] tg3 0000:02:00.0
        enp2s0: Flow control is off for TX and off for RX

[Booting 3.18.0:]
[    2.192915] tg3.c:v3.137 (May 11, 2014)
[    2.196767] libphy: tg3 mdio bus: probed
[    2.256294] tg3 0000:02:00.0 eth0:
        Tigon3 [partno(BCM57780) rev 57780001] (PCI Express) MAC address
        00:19:99:ce:13:a6
[    2.258387] tg3 0000:02:00.0 eth0:
        attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)
[    2.260530] tg3 0000:02:00.0 eth0:
        RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    2.262679] tg3 0000:02:00.0 eth0:
        dma_rwctrl[76180000] dma_mask[64-bit]
[...]
[    7.431176] tg3 0000:02:00.0
        enp2s0: renamed from eth0
[   10.422839] tg3 0000:02:00.0: irq 25 for MSI/MSI-X
[   12.530363] tg3 0000:02:00.0
        enp2s0: No firmware running

That's the last thing I find about the card in the logs, the machine
will then just sit there, working normally but being unreachable from
the network.

If I see things correctly, there were only two patches affecting tg3
between 3.17(.3) and 3.18:

2c7c9ea429ba30fe506747b7da110e2212d8fefa
a620a6bc1c94c22d6c312892be1e0ae171523125

The affected machine being, like I said, remote, I've not yet been
able to do more thorough tests. So I thought I'd report the issue and
see if someone else has also seen it already, or can test things with
a more easily accesible machine. Otherwise, I might start digging
deeper.

Greetings,
Nils
