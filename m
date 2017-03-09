From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: stmmac still supporting spear600 ?
Date: Thu, 9 Mar 2017 09:34:12 +0100
Message-ID: <20170309093412.33c0277d@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Viresh Kumar <vireshk@kernel.org>,
        Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
        linux-arm-kernel@lists.infradead.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:57653 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750798AbdCIIeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 03:34:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm porting Linux to an old spear600 based platform, and therefore
trying to use the stmmac driver on this SoC. Unfortunately, it doesn't
work quite well and I'm wondering if the stmmac driver still properly
supports the old version of the IP that is used in this SoC. I'm
testing with v4.11-rc1.

First, the logs:

Linux version 4.11.0-rc1 (thomas@skate) (gcc version 5.4.0 20160609 (Ubuntu/Linaro 5.4.0-6ubuntu1~16.04.4) ) #18 Thu Mar 9 09:18:01 CET 2017
[...]
libphy: Fixed MDIO Bus: probed
stmmaceth e0800000.ethernet: no reset control found
stmmac - user ID: 0x10, Synopsys ID: 0x32
stmmaceth e0800000.ethernet: Ring mode enabled
stmmaceth e0800000.ethernet: DMA HW capability register supported
stmmaceth e0800000.ethernet: Normal descriptors
libphy: stmmac: probed
stmmaceth e0800000.ethernet (unnamed net_device) (uninitialized): PHY ID 0007c0c4 at 31 IRQ POLL (stmmac-0:1f) active
[...]
# ifconfig eth0 192.168.1.89
stmmaceth e0800000.ethernet eth0: device MAC address 00:30:d3:21:22:60
Generic PHY stmmac-0:1f: attached PHY driver [Generic PHY] (mii_bus:phy_addr=stmmac-0:1f, irq=-1)
stmmaceth e0800000.ethernet: Failed to reset the dma
stmmaceth e0800000.ethernet eth0: stmmac_hw_setup: DMA engine initialization failed
stmmaceth e0800000.ethernet eth0: stmmac_open: Hw setup failed
ifconfig: SIOCSIFFLAGS: Device or resource busy

So the reason why it fails to reset the DMA is because
dwmac_dma_reset() sets bit DMA_BUS_MODE_SFT_RESET in register
DMA_BUS_MODE and waits for this bit to clear, but that never happens.

The reason why I'm not sure if this IP is still supported is because
dwmac1000_get_hw_feature() reads the DMA_HW_FEATURE register (offset
0x00001058), and my spear600 datasheet doesn't mention this register at
all.

It is worth mentioning that:

 - Ethernet is working fine under U-Boot (it's an old 2010.03 U-Boot
   version, with a good number of patches), so I'm sure the HW is
   working.

 - Setting bit 1 in the DMA_BUS_MODE register from U-Boot also leaves
   this bit set forever, it apparently never clears (unless my tests
   were wrong, which is very possible).

In terms of Device Tree, I'm simply using spear600.dtsi, and enabling
the gmac node, nothing else.

Has the stmmac driver been recently used/tested on spear600 ?

Thanks,

Thomas Petazzoni
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
