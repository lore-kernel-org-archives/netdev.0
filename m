From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: IRQF_SAMPLE_RANDOM question...
Date: Mon, 6 Apr 2009 14:30:26 -0400
Message-ID: <200904061430.26276.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>,
	Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:61614 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbZDFS2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 14:28:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although there was some discussion  
http://thread.gmane.org/gmane.linux.kernel/680723

about removing IRQF_SAMPLE_RANDOM from the remaining network drivers in May of 
2008, but they still appears to be there in 2.6.29.

drivers/net/ibmlana.c
drivers/net/macb.c
drivers/net/3c523.c
drivers/net/3c527.c
drivers/net/netxen/netxen_nic_main.c
drivers/net/cris/eth_v10.c
drivers/net/xen-netfront.c
drivers/net/atlx/atl1.c
drivers/net/qla3xxx.c
drivers/net/tg3.c
drivers/net/niu.c

So what is the plan? If I send a patch to add IRQF_SAMPLE_RANDOM to others 
(like the Blackfin) networking drivers - will it get rejected?

We have lots of embedded headless systems (no keyboard/mouse, no soundcard, no 
video) systems with *no* sources of entropy - and people using SSL.

I didn't really find any docs which describe what should have 
IRQF_SAMPLE_RANDOM on it or not. I did find Matt Mackall describing it as:
> We currently assume that IRQF_SAMPLE_RANDOM means 'this is a completely
> trusted unobservable entropy source' which is obviously wrong for
> network devices but is right for some other classes of device.

Currently - I see most things I see using IRQF_SAMPLE_RANDOM would also fail 
the "completely unobservable" test. Other than the TRNG that are inside the 
CPU - what does pass?

I can put a scope/analyser on a device - and look at the touchscreens, serial 
devices, USB, all without cracking the case. 

drivers/block/xen-blkfront.c:             Xen virtual block device frontend
drivers/i2c/busses/i2c-pmcmsp.c:          PMC MSP TWI/SMBus/I2C driver
drivers/input/keyboard/bf54x-keys.c:      Keypad driver for BF54x Processors
drivers/input/keyboard/gpio_keys.c:       Keyboard driver for CPU GPIOs
drivers/input/serio/hp_sdc.c:             HP i8042-based SDC Driver
drivers/input/touchscreen/wm97xx-core.c:  WM97xx Core - Touch Screen
drivers/serial/mpc52xx_uart.c:            Freescale MPC52xx PSC UART
drivers/serial/uartlite.c:                Xilinx uartlite serial driver
drivers/usb/gadget/omadrivers/usb/gadget/omap_udc	OMAP UDC driver

If I want to get more intrusive (expensive) - I can look at SPI, I2C, and 
other things that only might be observable at the PCB level (including things 
that are inside the chipset).

What are the guidelines for including IRQF_SAMPLE_RANDOM?

Thanks
-Robin
