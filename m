From: =?UTF-8?Q?Frank_Sch=c3=a4fer?= <fschaefer.oss@googlemail.com>
Subject: [4.5-rc7+ regression, bisected] libphy: PHY stmmac-0:ffffffff not
 found
Date: Tue, 8 Mar 2016 19:06:23 +0100
Message-ID: <56DF149F.6090100@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: gabriel.fernandez@linaro.org, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33886 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbcCHSEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 13:04:42 -0500
Received: by mail-wm0-f45.google.com with SMTP id p65so160799121wmp.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 10:04:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 88f8b1bb41c6208f81b6a480244533ded7b59493
Author: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Date:   Mon Feb 29 17:18:22 2016 +0100

    stmmac: Fix 'eth0: No PHY found' regression
  =20
    This patch manages the case when you have an Ethernet MAC with
    a "fixed link", and not connected to a normal MDIO-managed PHY devi=
ce.
  =20
    The test of phy_bus_name was not helpful because it was never affec=
ted
    and replaced by the mdio test node.
  =20
    Signed-off-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>
    Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


caused a regression on the Banana Pi M1 board:
=2E..
[    1.573419] sun7i-dwmac 1c50000.ethernet: no reset control found
[    1.583476]  Ring mode enabled
[    1.590476]  No HW DMA feature register supported
[    1.595153]  Normal descriptors
[    1.606075]  TX Checksum insertion supported
=2E..
[    9.430047] libphy: PHY stmmac-0:ffffffff not found
[    9.441829] eth0: Could not attach to PHY
[    9.452743] stmmac_open: Cannot attach to PHY (error: -19)

Reverting this commit makes it work again:

[    1.574459] sun7i-dwmac 1c50000.ethernet: no reset control found
[    1.584501]  Ring mode enabled
[    1.591491]  No HW DMA feature register supported
[    1.596169]  Normal descriptors
[    1.607076]  TX Checksum insertion supported
[    1.615766] sun7i-dwmac 1c50000.ethernet eth0: No MDIO subnode found
[    1.629108] libphy: stmmac: probed
[    1.636267] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
[    1.646446] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)
=2E..
[   10.086423]  RX IPC Checksum Offload disabled
[   10.097628]  No MAC Management Counters available
[   14.084839] sun7i-dwmac 1c50000.ethernet eth0: Link is Up -
100Mbps/Full - flow control rx/tx

Regards,
=46rank Sch=C3=A4fer
