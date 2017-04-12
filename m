From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Wed, 12 Apr 2017 15:05:58 +0200
Message-ID: <20170412150558.57c865e5@free-electrons.com>
References: <20170309093412.33c0277d@free-electrons.com>
        <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
        <20170309103236.3e16304f@free-electrons.com>
        <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
        <20170321155054.2f4cb921@free-electrons.com>
        <63405ec5-099c-b935-2724-6c85012fc9f7@st.com>
        <20170402233028.60acf612@free-electrons.com>
        <0468e2fb-5a7d-97ec-c51c-2436a13dda69@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, Viresh Kumar <vireshk@kernel.org>,
        Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56704 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdDLNGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 09:06:10 -0400
In-Reply-To: <0468e2fb-5a7d-97ec-c51c-2436a13dda69@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Thanks again for your answer, sorry for the delay, I was away from the
spear600 board for a while.

On Mon, 3 Apr 2017 08:16:50 +0200, Giuseppe CAVALLARO wrote:

> I tested the SMSC on other platform (+ stmmac), not on SPEAr.

OK. But I believe there might be a SPEAr specific issue here, which
might explain why you don't reproduce the problem.

> ok for reset, keep the radar on clock. Hmm, can you attach a piece of 
> log file to see the failure?

During the boot, nothing bad:

libphy: Fixed MDIO Bus: probed
stmmaceth e0800000.ethernet: no reset control found
stmmac - user ID: 0x10, Synopsys ID: 0x32
 Ring mode enabled
 DMA HW capability register supported Normal descriptors
libphy: stmmac: probed
eth0: PHY ID 0007c0c4 at 31 IRQ POLL (stmmac-0:1f) active

Then, when upping the interface:

# ifconfig eth0 up
eth0: device MAC address 00:30:d3:21:22:60
stmmaceth e0800000.ethernet: Failed to reset the dma
stmmac_hw_setup: DMA engine initialization failed
stmmac_open: Hw setup failed
SIOCSIFFLAGS: Device or resource busy

As I said earlier, the "Failed to reset the dma" is because
dwmac_dma_reset() returns -EBUSY because the DMA reset bit never
clears. Again, we see the same behavior in U-Boot (DMA reset bit never
clears), but Ethernet does work in U-Boot.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
