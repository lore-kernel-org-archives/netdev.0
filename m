From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Fri, 3 Feb 2017 09:54:27 +0000
Message-ID: <20170203095427.GA27312@n2100.armlinux.org.uk>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <20170202.215407.606581158337251076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, andrew@lunn.ch,
        maowenan@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:49996 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbdBCJyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:54:45 -0500
Content-Disposition: inline
In-Reply-To: <20170202.215407.606581158337251076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 09:54:07PM -0500, David Miller wrote:
> Hot plugging PHYs and notifications and all of that business is
> net-next material.

I was talking more about unbinding of the driver, which is something
that can be done today, eg:

$ ls -l /sys/bus/mdio_bus/drivers/Atheros\ 8035\ ethernet/
total 0
lrwxrwxrwx 1 root root    0 Feb  3 09:49 2188000.ethernet:00 -> ../../../../devices/soc0/soc/2100000.aips-bus/2188000.ethernet/mdio_bus/2188000.ethernet/2188000.ethernet:00
--w------- 1 root root 4096 Feb  3 09:49 bind
--w------- 1 root root 4096 Feb  3 09:49 uevent
--w------- 1 root root 4096 Feb  3 09:49 unbind
$ echo 2188000.ethernet:00 > /sys/bus/mdio_bus/drivers/Atheros\ 8035\ ethernet/unbind

is all it takes, and the same oops will happen.  Try it on a box
you don't care about crashing. :)

This is my point - locking the module into the kernel using
try_module_get() doesn't actually fix the problem where drivers are
concerned, it just has the illusion of being safe.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
