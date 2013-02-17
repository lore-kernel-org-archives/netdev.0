From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 1/2] net: fec: Do a sanity check on the gpio number
Date: Sun, 17 Feb 2013 13:32:03 +0800
Message-ID: <20130217053201.GB15048@S2101-09.ap.freescale.net>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <s.hauer@pengutronix.de>, <marex@denx.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:38315 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753616Ab3BQFcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 00:32:09 -0500
Content-Disposition: inline
In-Reply-To: <1361055207-22870-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 16, 2013 at 08:53:26PM -0200, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Since commit 372e722ea4d (gpiolib: use descriptors internally) the following 
> warning is seen on a mx28evk board:
> 
> [    5.116291] ------------[ cut here ]------------
> [    5.121306] WARNING: at drivers/gpio/gpiolib.c:125 gpio_to_desc+0x30/0x44()
> [    5.128491] invalid GPIO -2
> [    5.131563] Modules linked in:
> [    5.134846] [<c0014e20>] (unwind_backtrace+0x0/0xf4) from [<c001d428>] (warn_slowpath_common+0x4c/0x68)
> [    5.144682] [<c001d428>] (warn_slowpath_common+0x4c/0x68) from [<c001d4d8>] (warn_slowpath_fmt+0x30/0x40)
> [    5.154693] [<c001d4d8>] (warn_slowpath_fmt+0x30/0x40) from [<c0283434>] (gpio_to_desc+0x30/0x44)
> [    5.164002] [<c0283434>] (gpio_to_desc+0x30/0x44) from [<c0285470>] (gpio_request_one+0x10/0xe8)
> [    5.173294] [<c0285470>] (gpio_request_one+0x10/0xe8) from [<c0282f50>] (devm_gpio_request_one+0x40/0x74)
> [    5.183332] [<c0282f50>] (devm_gpio_request_one+0x40/0x74) from [<c0319be0>] (fec_probe+0x2d0/0x99c)
> [    5.192923] [<c0319be0>] (fec_probe+0x2d0/0x99c) from [<c02c8114>] (platform_drv_probe+0x14/0x18)
> [    5.202228] [<c02c8114>] (platform_drv_probe+0x14/0x18) from [<c02c6e00>] (driver_probe_device+0x90/0x224)
> [    5.212332] [<c02c6e00>] (driver_probe_device+0x90/0x224) from [<c02c7028>] (__driver_attach+0x94/0x98)
> [    5.222162] [<c02c7028>] (__driver_attach+0x94/0x98) from [<c02c5750>] (bus_for_each_dev+0x78/0x98)
> [    5.231642] [<c02c5750>] (bus_for_each_dev+0x78/0x98) from [<c02c5fd0>] (bus_add_driver+0x1a4/0x240)
> [    5.241207] [<c02c5fd0>] (bus_add_driver+0x1a4/0x240) from [<c02c7608>] (driver_register+0x78/0x140)
> [    5.250768] [<c02c7608>] (driver_register+0x78/0x140) from [<c00087a4>] (do_one_initcall+0x30/0x17c)
> [    5.260347] [<c00087a4>] (do_one_initcall+0x30/0x17c) from [<c05fa29c>] (kernel_init_freeable+0xe8/0x1b0)
> [    5.270381] [<c05fa29c>] (kernel_init_freeable+0xe8/0x1b0) from [<c044dfd4>] (kernel_init+0x8/0xe4)
> [    5.279886] [<c044dfd4>] (kernel_init+0x8/0xe4) from [<c000f248>] (ret_from_fork+0x14/0x2c)
> [    5.288740] ---[ end trace c15c72a22979d58d ]--- 
> 
> mx28evk has two ethernet controllers. The GPIO that performs the 
> ethernet reset on both ports is the same GPIO, so on the board dts file, only in
> one ethernet instance is passed the GPIO reset property.
> 
> Validate the gpio number prior to requesting it in order to avoid such warning.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Both

Acked-by: Shawn Guo <shawn.guo@linaro.org>
