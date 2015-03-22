From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH net-next V2 00/23] ptp: get ready for 2038
Date: Sun, 22 Mar 2015 03:43:35 +0100
Message-ID: <201503220343.35559.arnd@linaro.org>
References: <cover.1426973658.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Stefan =?iso-8859-15?q?S=F8rensen?=
	<stefan.sorensen@spectral
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1426973658.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 March 2015, Richard Cochran wrote:
> This series converts the core driver methods of the PTP Hardware Clock
> (PHC) subsystem to use the 64 bit version of the timespec structure,
> making the core API ready for the year 2038.
> 
> In addition, I reviewed how each driver and device represents the time
> value at the hardware register level.  Most of the drivers are ready,
> but a few will need some work before the year 2038, as shown:
> 
>    Patch   Driver
>    ------------------------------------------------
>    12      drivers/net/ethernet/intel/igb/igb_ptp.c
>    15 ?    drivers/net/ethernet/sfc/ptp.c
>    16      drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>    18 ?    drivers/net/ethernet/tile/tilegx.c
>    19      drivers/net/phy/dp83640.c
> 
> The commit log message documents how each driver is ready or why it is
> not ready.  For patches 15 and 18, I could not easily find out the
> hardware representation of the time value, so I would ask the
> maintainers for a review.

Very nice, thanks for joining in with the effort.

I've commented on a few smaller issues on individual patches.
Overall, I think we'd be slightly better off changing the type to
ktime_t for the interface, the main downside of that being that
we'd need to change a bit more code.

You'd still need to do the same kind of conversion, so the difference
would be very minor in the end though, so I'm fine with whichever
way you decide as the subsystem maintainer.

	Arnd
