From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Sat, 3 May 2008 21:01:56 +0100
Message-ID: <20080503200152.GO14219@solarflare.com>
References: <200804301925.m3UJPc72001651@hera.kernel.org> <20080501120858.207b6dd6.akpm@linux-foundation.org> <Pine.LNX.4.62.0805022004350.13626@dolphin.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michael Brown <mbrown@fensystems.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:46114 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751747AbYECUCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 16:02:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0805022004350.13626@dolphin.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Brown wrote:
> On Thu, 1 May 2008, Andrew Morton wrote:
> > >
> > > ...
> > >
> > > --- /dev/null
> > > +++ b/drivers/net/sfc/i2c-direct.h
> > 
> > There is no linkage with the kernel's own i2c layer?  Should there be?
> 
> Last time I checked (i.e. when I originally wrote this bit of the code), 
> the kernel's own i2c layer didn't provide any clean way for kernel code 
> (rather than user code) to access i2c devices.

You may be thinking of the lm87 sensor driver, which exposes its
configuration through sysfs (iirc) and not through specific kernel
functions.  There was an I2C module for EF1 boards that worked with lm87
and the I2C framework, but it was removed along with all EF1 support.
Perhaps I should look at adapting that to the Falcon boards.  We would
still want to do at least the initial programming of the sensors from the
sfc driver though.

> As originally written, there was also a link to the kernel's i2c layer so 
> that the NIC's onboard i2c bus could be exposed to e.g. lm_sensors for 
> temperature monitoring.  I believe that this part of the driver was 
> expunged since it made the patch "too large", but I may be wrong.

The temperature and voltage monitoring was not included.  In the submitted
driver, the I2C code is needed for power control and setting the over-
temperature cut-out value on SFE4001 boards.  These use a MAX6647, not an
LM87.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
