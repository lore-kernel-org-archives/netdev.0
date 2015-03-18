From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [PATCH] net: macb: fix endian code for avr32
Date: Wed, 18 Mar 2015 13:25:38 +0100
Message-ID: <20150318122538.GA19497@samfundet.no>
References: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@lists.codethink.co.uk,
	Linux Networking List <netdev@vger.kernel.org>,
	Arun Chandran <achandran@mvista.com>,
	Haavard Skinnemoen <hskinnemoen@gmail.com>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Around Wed 18 Mar 2015 10:57:27 +0000 or thereabout, Ben Dooks wrote:
> [note this has yet to be compile tested on avr32]
>

Compiles fine without warnings.

> The changes to run the macb driver in 29af05aeb98e ("net: macb:
> Add big endian CPU support") to support big endian operation on
> ARM may not work on AVR32 which already is naturally big endian
> architecture (and the driver already works here).

The 29af05aeb98e will brick the macb driver for AVR32, as readZ_relaxed
translates to readZ calls, which turns into le_to_cpu reads.

> In this case  the readl/writel relaxed will do the opposite of __raw
> accesors which arleady work. Add an indirection of cdneth_ prefixed
> accesors which are changed as necessary. Also do not issue the DMA
> descritpor endian fetch configuration for AVR32.
> 
> From discussions with Arnd Bergman, the following fix changes the use
> of readl_relaxed and writel_relaxed with a version that can be put
> back to __raw_readl/__raw_writel for the CONFIG_AVR32 case (and also
> remove the change to the DMA descriptor endian).

Thank you for spotting this.

> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> Reported-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

> --
> CC: Linux Networking List <netdev@vger.kernel.org>
> CC: Arun Chandran <achandran@mvista.com>
> CC: Haavard Skinnemoen <hskinnemoen@gmail.com>
> CC: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> CC: Linux Kernel List <linux-kernel@vger.kernel.org>
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 14 +++++++-------
>  drivers/net/ethernet/cadence/macb.h | 20 ++++++++++++++------
>  2 files changed, 21 insertions(+), 13 deletions(-)

<snipp diff>

-- 
BR, HcE
