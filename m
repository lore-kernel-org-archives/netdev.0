From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: stmmac still supporting spear600 ?
Date: Thu, 20 Apr 2017 22:01:39 +0200
Message-ID: <20170420220139.6dcc6224@free-electrons.com>
References: <20170309093412.33c0277d@free-electrons.com>
 <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
 <20170309103236.3e16304f@free-electrons.com>
 <79049eda-5d37-6b70-8945-2d3ab55e56b8@st.com>
 <20170321155054.2f4cb921@free-electrons.com>
 <63405ec5-099c-b935-2724-6c85012fc9f7@st.com>
 <20170402233028.60acf612@free-electrons.com>
 <0468e2fb-5a7d-97ec-c51c-2436a13dda69@st.com>
 <20170412150558.57c865e5@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexandre Torgue <alexandre.torgue@st.com>,
 linux-arm-kernel@lists.infradead.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>, Shiraz Hashim
 <shiraz.linux.kernel@gmail.com>, Viresh Kumar <vireshk@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170412150558.57c865e5@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Viresh, Shiraz,

As the SPEAr600 platform maintainers, have you tested Ethernet in
recent times, especially with a MII PHY ? I'm still struggling to get
it working. Quick summary:

 - The same kernel works fine on another SPEAr600 platform that has a
   GMII PHY

 - The SPEAr600 platform with a MII PHY has Ethernet working fine under
   U-Boot (TFTP works), so the HW is known to be working.

 - I've compared the values of the MAC registers between U-Boot and
   Linux, and traced all the PHY registers read/write over the MDIO
   bus, and compared the traces between U-Boot and Linux. Found a few
   differences, but solving them didn't change the problem.

I'm suspecting the problem is not directly in the MAC/PHY
configuration. Would you have some hints like clock configuration, or
other system-level configuration that could affect this? Especially the
TXCLK from the PHY is not coming in through the same pin when in GMII
and MII mode it seems. Does this needs some special configuration?

Any hint/idea would definitely be welcome.

Thanks a lot!

Thomas

On Wed, 12 Apr 2017 15:05:58 +0200, Thomas Petazzoni wrote:
> Hello,
> 
> Thanks again for your answer, sorry for the delay, I was away from the
> spear600 board for a while.
> 
> On Mon, 3 Apr 2017 08:16:50 +0200, Giuseppe CAVALLARO wrote:
> 
> > I tested the SMSC on other platform (+ stmmac), not on SPEAr.  
> 
> OK. But I believe there might be a SPEAr specific issue here, which
> might explain why you don't reproduce the problem.
> 
> > ok for reset, keep the radar on clock. Hmm, can you attach a piece of 
> > log file to see the failure?  
> 
> During the boot, nothing bad:
> 
> libphy: Fixed MDIO Bus: probed
> stmmaceth e0800000.ethernet: no reset control found
> stmmac - user ID: 0x10, Synopsys ID: 0x32
>  Ring mode enabled
>  DMA HW capability register supported Normal descriptors
> libphy: stmmac: probed
> eth0: PHY ID 0007c0c4 at 31 IRQ POLL (stmmac-0:1f) active
> 
> Then, when upping the interface:
> 
> # ifconfig eth0 up
> eth0: device MAC address 00:30:d3:21:22:60
> stmmaceth e0800000.ethernet: Failed to reset the dma
> stmmac_hw_setup: DMA engine initialization failed
> stmmac_open: Hw setup failed
> SIOCSIFFLAGS: Device or resource busy
> 
> As I said earlier, the "Failed to reset the dma" is because
> dwmac_dma_reset() returns -EBUSY because the DMA reset bit never
> clears. Again, we see the same behavior in U-Boot (DMA reset bit never
> clears), but Ethernet does work in U-Boot.
> 
> Best regards,
> 
> Thomas



-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
