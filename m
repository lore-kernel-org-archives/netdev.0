From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Fri, 3 Feb 2017 13:04:40 -0800
Message-ID: <88fb901e-47e3-698b-d111-7e965ca6760a@gmail.com>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <20170202.215407.606581158337251076.davem@davemloft.net>
 <20170203095427.GA27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, maowenan@huawei.com
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33779 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:04:42 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so2870771pgd.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:04:42 -0800 (PST)
In-Reply-To: <20170203095427.GA27312@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 01:54 AM, Russell King - ARM Linux wrote:
> On Thu, Feb 02, 2017 at 09:54:07PM -0500, David Miller wrote:
>> Hot plugging PHYs and notifications and all of that business is
>> net-next material.
> 
> I was talking more about unbinding of the driver, which is something
> that can be done today, eg:
> 
> $ ls -l /sys/bus/mdio_bus/drivers/Atheros\ 8035\ ethernet/
> total 0
> lrwxrwxrwx 1 root root    0 Feb  3 09:49 2188000.ethernet:00 -> ../../../../devices/soc0/soc/2100000.aips-bus/2188000.ethernet/mdio_bus/2188000.ethernet/2188000.ethernet:00
> --w------- 1 root root 4096 Feb  3 09:49 bind
> --w------- 1 root root 4096 Feb  3 09:49 uevent
> --w------- 1 root root 4096 Feb  3 09:49 unbind
> $ echo 2188000.ethernet:00 > /sys/bus/mdio_bus/drivers/Atheros\ 8035\ ethernet/unbind
> 
> is all it takes, and the same oops will happen.  Try it on a box
> you don't care about crashing. :)
> 
> This is my point - locking the module into the kernel using
> try_module_get() doesn't actually fix the problem where drivers are
> concerned, it just has the illusion of being safe.

I have some patches for that too, along with making bind, unbind work
again, because the state machine seems to be hosed (another thing that
was very well tested...).
-- 
Florian
