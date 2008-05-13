From: Jean Delvare <khali@linux-fr.org>
Subject: SFC driver implements its own I2C support
Date: Tue, 13 May 2008 10:33:25 +0200
Message-ID: <20080513103325.1ab317cf@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux I2C <i2c@lm-sensors.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:21284 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508AbYEMIdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 04:33:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben, hi Jeff,

My attention was brought to the drivers/net/sfc/i2c-direct.c file which
appeared recently in the Linux kernel. Apparently this is a custom
implementation of I2C support, including software bit-banging. All this
is already available in the Linux kernel in:
  drivers/i2c/i2c-core.c
  drivers/i2c/algos/i2c-algo-bit.c
So it really doesn't make sense to duplicate the code in the sfc
network driver.

Can you please get rid of this custom I2C implementation and use the
standard one? It should be really easy, all you have to do is include
<linux/i2c.h> and <linux/i2c-algo-bit.h>, pack your SDA and SCL get/set
functions in a struct i2c_algo_bit_data, and call i2c_bit_add_bus() on
it. See drivers/video/intelfb/intelfb_i2c.c (or any framebuffer driver
with I2C/DDC support) for an example.

Using the standard I2C implementation will give you access to all the
i2c debugging tools, user-space access to the I2C bus if needed, and
compatibility with all the Linux i2c device drivers, including hardware
monitoring and GPIO drivers which apparently the SFC hardware uses.

Thanks,
-- 
Jean Delvare
