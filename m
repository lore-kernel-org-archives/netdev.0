From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: Fix conversion from host device to mii bus
Date: Fri, 17 Oct 2014 23:52:34 -0400 (EDT)
Message-ID: <20141017.235234.1984288210914297505.davem@davemloft.net>
References: <1413574258-21766-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413574258-21766-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Fri, 17 Oct 2014 12:30:58 -0700

> Commit b4d2394d01bc ("dsa: Replace mii_bus with a generic host device")
> replaces mii_bus with a generic host_dev, and introduces
> dsa_host_dev_to_mii_bus() to support conversion from host_dev to mii_bus.
> However, in some cases it uses to_mii_bus to perform that conversion.
> Since host_dev is not the phy bus device but typically a platform device,
> this fails and results in a crash with the affected drivers.
> 
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<ffffffff81781d35>] __mutex_lock_slowpath+0x75/0x100
> PGD 406783067 PUD 406784067 PMD 0
> Oops: 0002 [#1] SMP
> ...
> Call Trace:
> [<ffffffff810a538b>] ? pick_next_task_fair+0x61b/0x880
> [<ffffffff81781de3>] mutex_lock+0x23/0x37
> [<ffffffff81533244>] mdiobus_read+0x34/0x60
> [<ffffffff8153b95a>] __mv88e6xxx_reg_read+0x8a/0xa0
> [<ffffffff8153b9bc>] mv88e6xxx_reg_read+0x4c/0xa0
> 
> Fixes: b4d2394d01bc ("dsa: Replace mii_bus with a generic host device")
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
