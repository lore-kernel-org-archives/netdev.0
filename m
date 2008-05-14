From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: SFC driver implements its own I2C support
Date: Wed, 14 May 2008 22:58:20 +0100
Message-ID: <20080514215818.GH28241@solarflare.com>
References: <20080513103325.1ab317cf@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	Linux I2C <i2c@lm-sensors.org>,
	linux-net-drivers@solarflare.com
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:46238 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751322AbYENWA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 18:00:28 -0400
Content-Disposition: inline
In-Reply-To: <20080513103325.1ab317cf@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Delvare wrote:
> Hi Ben, hi Jeff,

Please use the address linux-net-drivers@solarflare.com, as listed in
MAINTAINERS, which goes to everyone working on the sfc driver here.

> My attention was brought to the drivers/net/sfc/i2c-direct.c file which
> appeared recently in the Linux kernel. Apparently this is a custom
> implementation of I2C support, including software bit-banging. All this
> is already available in the Linux kernel in:
>   drivers/i2c/i2c-core.c
>   drivers/i2c/algos/i2c-algo-bit.c
> So it really doesn't make sense to duplicate the code in the sfc
> network driver.
>
> Can you please get rid of this custom I2C implementation and use the
> standard one?

We intend to do so, but may not be able to do it before 2.6.26.

> It should be really easy, all you have to do is include
> <linux/i2c.h> and <linux/i2c-algo-bit.h>, pack your SDA and SCL get/set
> functions in a struct i2c_algo_bit_data, and call i2c_bit_add_bus() on
> it. See drivers/video/intelfb/intelfb_i2c.c (or any framebuffer driver
> with I2C/DDC support) for an example.

I have made a start on this, and it looked like it would be a bit more
difficult than that.  But then perhaps I was doing more work than I
really needed to.

Also, see comments from the original author of our I2C code in
<http://thread.gmane.org/gmane.linux.kernel.commits.head/145999/focus=92866>.

> Using the standard I2C implementation will give you access to all the
> i2c debugging tools, user-space access to the I2C bus if needed, and
> compatibility with all the Linux i2c device drivers, including hardware
> monitoring and GPIO drivers which apparently the SFC hardware uses.

Right.  But the most immediate requirement is that we be able to
configure I2C devices from the sfc driver.  Most of our reference
designs require that as part of their initialisation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
