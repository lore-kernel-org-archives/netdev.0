From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [4.5-rc7+ regression, bisected] libphy: PHY stmmac-0:ffffffff
 not found
Date: Wed, 9 Mar 2016 08:53:57 +0100
Message-ID: <56DFD695.1050300@st.com>
References: <56DF149F.6090100@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss@googlemail.com>,
	<gabriel.fernandez@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33036 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751246AbcCIHyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:54:01 -0500
In-Reply-To: <56DF149F.6090100@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Frank

yes we are also looking at this problem in this thread:

   [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement

I am implementing a patch and I will propose it soon.

Peppe

On 3/8/2016 7:06 PM, Frank Sch=C3=A4fer wrote:
> commit 88f8b1bb41c6208f81b6a480244533ded7b59493
> Author: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> Date:   Mon Feb 29 17:18:22 2016 +0100
>
>      stmmac: Fix 'eth0: No PHY found' regression
>
>      This patch manages the case when you have an Ethernet MAC with
>      a "fixed link", and not connected to a normal MDIO-managed PHY d=
evice.
>
>      The test of phy_bus_name was not helpful because it was never af=
fected
>      and replaced by the mdio test node.
>
>      Signed-off-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>
>      Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
> caused a regression on the Banana Pi M1 board:
> ...
> [    1.573419] sun7i-dwmac 1c50000.ethernet: no reset control found
> [    1.583476]  Ring mode enabled
> [    1.590476]  No HW DMA feature register supported
> [    1.595153]  Normal descriptors
> [    1.606075]  TX Checksum insertion supported
> ...
> [    9.430047] libphy: PHY stmmac-0:ffffffff not found
> [    9.441829] eth0: Could not attach to PHY
> [    9.452743] stmmac_open: Cannot attach to PHY (error: -19)
>
> Reverting this commit makes it work again:
>
> [    1.574459] sun7i-dwmac 1c50000.ethernet: no reset control found
> [    1.584501]  Ring mode enabled
> [    1.591491]  No HW DMA feature register supported
> [    1.596169]  Normal descriptors
> [    1.607076]  TX Checksum insertion supported
> [    1.615766] sun7i-dwmac 1c50000.ethernet eth0: No MDIO subnode fou=
nd
> [    1.629108] libphy: stmmac: probed
> [    1.636267] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) acti=
ve
> [    1.646446] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)
> ...
> [   10.086423]  RX IPC Checksum Offload disabled
> [   10.097628]  No MAC Management Counters available
> [   14.084839] sun7i-dwmac 1c50000.ethernet eth0: Link is Up -
> 100Mbps/Full - flow control rx/tx
>
> Regards,
> Frank Sch=C3=A4fer
>
>
