From: Chen-Yu Tsai <wens@csie.org>
Subject: net: stmmac: DT clock parameter and behavior?
Date: Tue, 19 Nov 2013 22:17:34 +0800
Message-ID: <CAGb2v65G70x-nqg2pJ2dTovgT-b9n+5JCeABzD0ft1JqPm6f4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58356 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab3KSOR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:17:58 -0500
Received: by mail-vb0-f46.google.com with SMTP id i3so3741711vbh.19
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 06:17:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am currently porting the Linux stmmac driver to an AllWinner SoC
board. The AllWinner A20 SoC has a GMAC, and the drivers they provided
seems to be an early version of stmmac, with the names replaced.
I assume the IP in the SoC is an early version of dwmac. So far I have
managed to get a running system. I would like to clarify a few details
to clean up the code.

The stmmac core code references a clock named "stmmaceth".
This clock does not seem to be documented in "networking/stmmac.txt"
nor in "devicetree/bindings/net/stmmac.txt".
STMicroelectronics SPEAr board DTs do not mention this clock.
But I do see Altera SoCFPGA and Samsung Exynos DTs defining it.

The latest patch series for dwmac-sti on netdev suggests that this
clock is a 25MHz clock for the phy device. Is this true?

Then the driver does not consider that the dwmac might have a gated
clock that needs to be enabled as well. I ran into problems when
the dwmac was not initialized by the bootloader. I assume this can
be dealt with using AUXDATA and .init/.exit callbacks?

Also, earlier versions of stmmac seemed to only give a warning if
"stmmaceth" clock was not found. But in

    6a81c26f  net/stmmac: remove conditional compilation of clk code

the behavior changed to failing completely. Was this intended?

Last, given the supported device is actually Synopsys DesignWare
Ethernet MAC, is there any chance the driver could be renamed to dwmac?


Thank You

Chen-Yu Tsai
