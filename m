From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v11 4/5] powerpc: Add flexcan device support for p1010rdb.
Date: Wed, 10 Aug 2011 20:16:33 +0200
Message-ID: <4E42CB01.7030700@grandegger.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com>	<1312993670-23999-5-git-send-email-holt@sgi.com>
	<8E5FA886-038D-4DF4-8A54-DD60188A21A2@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8E5FA886-038D-4DF4-8A54-DD60188A21A2-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
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

On 08/10/2011 07:01 PM, Kumar Gala wrote:
> 
> On Aug 10, 2011, at 11:27 AM, Robin Holt wrote:
> 
>> I added a simple clock source for the p1010rdb so the flexcan driver
>> could determine a clock frequency.  The p1010 flexcan device only has
>> an oscillator of system bus frequency divided by 2.
>>
>> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
>> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
>> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
>> Cc: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
>> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
>> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
>> ---
>> arch/powerpc/platforms/85xx/Kconfig    |    2 +
>> arch/powerpc/platforms/85xx/Makefile   |    2 +
>> arch/powerpc/platforms/85xx/clock.c    |   52 ++++++++++++++++++++++++++++++++
>> arch/powerpc/platforms/85xx/p1010rdb.c |    8 +++++
>> 4 files changed, 64 insertions(+), 0 deletions(-)
>> create mode 100644 arch/powerpc/platforms/85xx/clock.c
> 
> I dont understand how mpc85xx_clk_functions() ends up being associated with the frequency the flexcan is running at.

The function mpc85xx_clk_get_rate() returns "fsl_get_sys_freq() / 2" for
Flexcan devices.

> This either seems to global or I'm missing something.

This patch extends the existing Flexcan platform driver for ARM for the
PowerPC using the device tree. Due to the nice integration of the device
tree (of-platform) into the platform driver and devices, the difference
are quite small (see patches 1..3). Apart from the endianess issue, only
the clock needs to be handled in a common way. As ARM already uses the
clk interface, we found it straight-forward to implement it for the
P1010, or more general for the 85xx, as well, instead of using an
additional helper function.

> I still think the clk / freq info should be in the device tree and handled in the driver and NOT arch/powerpc platform code.

If I understand you correctly, you want the boot-loader to provide the
relevant information by fixing up the device tree, which then can be
handled arch-independently by the driver, right?

Wolfgang.
