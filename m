From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Fri, 8 Jan 2016 15:58:48 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404944FF@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com>
 <20160108004238.GD4389@lunn.ch> <568F1A1B.1040808@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D4049389F@CHN-SV-EXMX02.mchp-main.com>
 <20160108155111.GF4389@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:49432 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755370AbcAHP6u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 10:58:50 -0500
In-Reply-To: <20160108155111.GF4389@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your information. I'll take a look.

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, January 08, 2016 10:51 AM
> To: Woojung Huh - C21699
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH] net: phy: Support for non-HW interrupt devices
> 
> > As you may already know, USB Interrupt Pipe is not actual interrupt and
> > USB driver is beyond USB Host driver which deals with HW interrupt directly
> over
> > request_irq(). So even we can put some code in USB Host driver to
> interface with
> > PHYLIB, it is more likely adding another USB stack to handle this pseudo
> interrupt.
> > I don't think it's good approach to solve this problem.
> 
> You don't need any code in the USB irq handler.
> 
> I'm not too familiar with USB networking, but looking at usbnet.c, it
> looks like intr_complete() gets called when there is a USB Interrupt
> Pipe event. That calls into the drivers status() method.
> 
> In this status method, you need to trigger a Linux interrupt. By that,
> i mean you need to call handle_nested_irq().
> 
> What i found useful was looking at how drivers/gpio/gpip-pca953x.c
> works. That is an i2c GPIO expander, which supports GPIO
> interrupts. When the device indicates an interrupt event, you need to
> read an i2c register on the device to see which GPIO line has
> triggered it, and then call handle_nestd_irq() for the corresponding
> interrupt.
> 
> Humm, in fact, take a look at drivers/gpio/gpio-dln2.c It is a USB
> GPIO expander, with interrupt support.
> 
> 	Andrew
