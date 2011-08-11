From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v11 4/5] powerpc: Add flexcan device support for p1010rdb.
Date: Thu, 11 Aug 2011 05:42:52 -0500
Message-ID: <20110811104252.GC4926@sgi.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>
	<1312993670-23999-5-git-send-email-holt@sgi.com>
	<8E5FA886-038D-4DF4-8A54-DD60188A21A2@kernel.crashing.org>
	<4E42CB01.7030700@grandegger.com>
	<634AB7A6-1CDA-41B3-8A5D-01F29EF01521@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <634AB7A6-1CDA-41B3-8A5D-01F29EF01521-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 10, 2011 at 11:46:27PM -0500, Kumar Gala wrote:
> 
> On Aug 10, 2011, at 1:16 PM, Wolfgang Grandegger wrote:
> 
> > On 08/10/2011 07:01 PM, Kumar Gala wrote:
> >> 
> >> On Aug 10, 2011, at 11:27 AM, Robin Holt wrote:
> >> 
> >>> I added a simple clock source for the p1010rdb so the flexcan driver
> >>> could determine a clock frequency.  The p1010 flexcan device only has
> >>> an oscillator of system bus frequency divided by 2.
> >>> 
> >>> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> >>> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> >>> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> >>> Cc: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> >>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> >>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> >>> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> >>> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> >>> ---
> >>> arch/powerpc/platforms/85xx/Kconfig    |    2 +
> >>> arch/powerpc/platforms/85xx/Makefile   |    2 +
> >>> arch/powerpc/platforms/85xx/clock.c    |   52 ++++++++++++++++++++++++++++++++
> >>> arch/powerpc/platforms/85xx/p1010rdb.c |    8 +++++
> >>> 4 files changed, 64 insertions(+), 0 deletions(-)
> >>> create mode 100644 arch/powerpc/platforms/85xx/clock.c
> >> 
> >> I dont understand how mpc85xx_clk_functions() ends up being associated with the frequency the flexcan is running at.
> > 
> > The function mpc85xx_clk_get_rate() returns "fsl_get_sys_freq() / 2" for
> > Flexcan devices.
> > 
> >> This either seems to global or I'm missing something.
> > 
> > This patch extends the existing Flexcan platform driver for ARM for the
> > PowerPC using the device tree. Due to the nice integration of the device
> > tree (of-platform) into the platform driver and devices, the difference
> > are quite small (see patches 1..3). Apart from the endianess issue, only
> > the clock needs to be handled in a common way. As ARM already uses the
> > clk interface, we found it straight-forward to implement it for the
> > P1010, or more general for the 85xx, as well, instead of using an
> > additional helper function.
> 
> I see, that.  What concerns me is there are numerous clocks /
> frequencies that exist inside a MPC85xx/P1010 SOC.  The code I'm seeing
> does NOT seem to do anything to relate this clock JUST to the flexcan.

        if (!dev->of_node ||
            !of_device_is_compatible(dev->of_node, "fsl,flexcan"))
                return ERR_PTR(-ENOENT);

That should relate it just to flexcan, right?  Plus it has the added
benefit of being a baby-step in the direction of implementing a clkdev
type thing for powerpc which did look fairly slick to me, but I may
be confused.

It sounds like Wolfgang is defering to you.  Give it an honest evaluation
and tell me which direction you would like me to go.  I don't have a
strong preference either way.  The alternative I gave to Wolfgang of
using a flexcan property to avoid needing any clk_get_rate seems fairly
hackish at this point, but I have had more time to get used to the
'hack in a 85xx clock' method.

Thanks,
Robin
