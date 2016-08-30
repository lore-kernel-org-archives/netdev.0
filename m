From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH 0/4] SA11x0 Clocks and removal of Neponset SMC91x hack
Date: Tue, 30 Aug 2016 11:31:15 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1608301129520.1525@knanqh.ubzr>
References: <20160829120531.GG1041@n2100.armlinux.org.uk>
 <E1beLKT-0001U1-HK@rmk-PC.armlinux.org.uk>
 <20160830105117.GM1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160830105117.GM1041@n2100.armlinux.org.uk>
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

On Tue, 30 Aug 2016, Russell King - ARM Linux wrote:

> This mini-series (which follows several other series on which it
> depends) gets rid of the Assabet/Neponset hack in the smc91x driver.
> 
> In order to do that, we need to get several pieces in place first:
> * gpiolib support throughout SA11x0/Assabet/Neponset so that we can
>   represent control signals through gpiolib
> * CCF support, so we can re-use the code in drivers/clk to implement
>   the external crystal oscillator attached to the SMC91x.  This
>   external crystal oscillator is enabled via a control signal.
> 
> This series:
> - performs the SA11x0 CCF conversion
> - adds an optional clock to SMC91x to cater for an external crystal
>   oscillator
> - switches the Neponset code to provide a 'struct clk' representing
>   this oscillator
> - removes the SMC91x hack to assert the enable signal
> 
> This results in the platform specific includes being removed from the
> SMC91x driver.
> 
> Please ack these changes; due to the dependencies, I wish to merge
> them through my tree.  Thanks.

Looks nice to me.

Acked-by: Nicolas Pitre <nico@linaro.org>

>  arch/arm/Kconfig                   |   1 +
>  arch/arm/mach-sa1100/clock.c       | 191 +++++++++++++++++--------------------
>  arch/arm/mach-sa1100/neponset.c    |  42 ++++++++
>  drivers/net/ethernet/smsc/smc91x.c |  47 ++++++---
>  drivers/net/ethernet/smsc/smc91x.h |   1 +
>  5 files changed, 166 insertions(+), 116 deletions(-)
> 
> -- 
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
