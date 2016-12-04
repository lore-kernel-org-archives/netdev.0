From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: 'imply' ptp instead of 'select'
Date: Sat, 03 Dec 2016 23:39:45 -0500 (EST)
Message-ID: <20161203.233945.1757084444220812603.davem@davemloft.net>
References: <20161202230451.1639318-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix.manlunas@caviumnetworks.com, tglx@linutronix.de,
        david.daney@cavium.com, satananda.burla@caviumnetworks.com,
        rvatsavayi@caviumnetworks.com, nicolas.pitre@linaro.org,
        sgoutham@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202230451.1639318-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat,  3 Dec 2016 00:04:32 +0100

> ptp now depends on the optional POSIX_TIMERS setting and fails to build
> if we select it without that:
> 
> warning: (LIQUIDIO_VF && TI_CPTS) selects PTP_1588_CLOCK which has unmet direct dependencies (NET && POSIX_TIMERS)
> warning: (LIQUIDIO_VF && TI_CPTS) selects PTP_1588_CLOCK which has unmet direct dependencies (NET && POSIX_TIMERS)
> ERROR: "posix_clock_unregister" [drivers/ptp/ptp.ko] undefined!
> ERROR: "posix_clock_register" [drivers/ptp/ptp.ko] undefined!
> ERROR: "pps_unregister_source" [drivers/ptp/ptp.ko] undefined!
> ERROR: "pps_event" [drivers/ptp/ptp.ko] undefined!
> ERROR: "pps_register_source" [drivers/ptp/ptp.ko] undefined!
> 
> It seems that two patches have collided here, the build failure
> is a result of the combination. Changing the new option to 'imply'
> as well fixes it.
> 
> Fixes: 111fc64a237f ("liquidio CN23XX: VF registration")
> Fixes: d1cbfd771ce8 ("ptp_clock: Allow for it to be optional")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Like the kbuild robot, when I apply this it complains about 'imply' being
an unknown option.

I guess it worked for you because support for 'imply' exists in the -next
tree and gets pulled in from somewhere else.

In any event, as-is I cannot apply this.
