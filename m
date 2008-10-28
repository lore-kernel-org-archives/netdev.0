From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Tue, 28 Oct 2008 10:55:37 +0200
Message-ID: <4906D389.5050706@teltonika.lt>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <20081027143734.GA13565@secretlab.ca> <200810270941.03258.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:50448 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752536AbYJ1JCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 05:02:45 -0400
In-Reply-To: <200810270941.03258.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> On Monday 27 October 2008, Grant Likely wrote:
>> On Mon, Oct 27, 2008 at 12:53:22PM +0200, Paulius Zaleckas wrote:
>>> Useful for machines where PHY control is connected to GPIO.
>>> This driver also supports interrupts from PHY.
> 
> I get a kick out of seeing each new generic driver using
> the generic GPIO interface.  I *should* have expected it,
> obviously.  ;)
> 
> With a few exceptions I'll second Grant's comments, and
> pick a few more nits.

Thanks for review!

> 
>>> +#include <linux/kernel.h>
>>> +#include <linux/init.h>
>>> +#include <linux/platform_device.h>
>>> +#include <linux/gpio.h>
>>> +#include <linux/mdio-bitbang.h>
>>> +#include <linux/mdio-gpio.h>
>> Missing:
>>
>> MODULE_AUTHOR()
>> MODULE_LICENSE()
>> MODULE_DESCRIPTION()
> 
> ... which many of us like to see at the *end* of the driver,
> with other module housekeeping (driver registration), instead
> of duplicating the header contents we just saw.
> 
> 
>>> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> 
> There are a few cases where platform drivers can't use __init
> and platform_driver_probe(), instead of __devinit paired with
> platform_driver_register().  Does this need to be one of them?
> 
> That is, are these platform devices going to be hotplugged?
> (Usually because they are driver model children of other devices
> which get hotplugged.)

I think there is possibility that this driver will be hotplugged...
I agree that all devices that are explicitly on the SoC itself
have to use __init and platform_driver_probe(), but it is not
the case for this one... I will add MODULE_ALIAS for udev.

> 
>>> +out:
>>> +	return ret;
>> Nit:  labels in column 0 will confuse diff when it tries to put the
>> function name in the diff hunk header.  If you indent the labels by 1
>> space then future diffs will show the function name instead of the label
>> name in diff hunk headers.
> 
> ... but please don't change drivers to work around cosmitic diff bugs ...
> 
> 
>>> +static int __devexit mdio_gpio_remove(struct platform_device *pdev)
> 
> As above:  if these devices are really hotpluggable, so be it.
> But that's the exception for platform_device nodes, not the rule,
> so I'd normally use __exit here (and __exit_p in the driver
> structure, later) to shrink the runtime code footprint.
