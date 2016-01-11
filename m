From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Mon, 11 Jan 2016 20:33:11 +0100
Message-ID: <201601112033.11487.marex@denx.de>
References: <201601120324.lYD7L0Bs%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:36636 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817AbcAKTdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 14:33:11 -0500
In-Reply-To: <201601120324.lYD7L0Bs%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, January 11, 2016 at 08:29:28 PM, kbuild test robot wrote:
> Hi Marek,

Hi Robot,

> [auto build test WARNING on net/master]
> [also build test WARNING on v4.4 next-20160111]
> [if your patch is applied to the wrong git tree, please drop us a note to
> help improving the system]
> 
> url:   
> https://github.com/0day-ci/linux/commits/Marek-Vasut/net-can-Sort-the-Kcon
> fig-includes/20160112-025020 config: x86_64-allmodconfig (attached as
> .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
> 
> All warnings (new ones prefixed by >>):
> 
>    drivers/net/can/ifi_canfd/ifi_canfd.c: In function 'ifi_canfd_isr':
> >> drivers/net/can/ifi_canfd/ifi_canfd.c:486:27: warning: large integer
> >> implicitly truncated to unsigned type [-Woverflow]
> 
>      const u32 clr_irq_mask = ~(IFI_CANFD_INTERRUPT_SET_IRQ |
>                               ^
>    drivers/net/can/ifi_canfd/ifi_canfd.c: In function 'ifi_canfd_start':
>    drivers/net/can/ifi_canfd/ifi_canfd.c:640:9: warning: large integer
> implicitly truncated to unsigned type [-Woverflow]
> writel(~IFI_CANFD_INTERRUPT_SET_IRQ, priv->base + IFI_CANFD_INTERRUPT); ^
>    drivers/net/can/ifi_canfd/ifi_canfd.c: In function 'ifi_canfd_stop':
>    drivers/net/can/ifi_canfd/ifi_canfd.c:675:9: warning: large integer
> implicitly truncated to unsigned type [-Woverflow]
> writel(~IFI_CANFD_INTERRUPT_SET_IRQ, priv->base + IFI_CANFD_INTERRUPT); ^

How did this splat came to be ? I would expect that the expansion goes like
this:

const u32 clr_irq_mask = ~(IFI_CANFD_INTERRUPT_SET_IRQ |
                           IFI_CANFD_INTERRUPT_ERROR_WARNING);
const u32 clr_irq_mask = ~(BIT(31) | BIT(1));
const u32 clr_irq_mask = ~(0x80000002);
const u32 clr_irq_mask = 0x7ffffffd;

Did I miss something there ?

Thanks!

Best regards,
Marek Vasut
