From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH net-next] liquidio: 'imply' ptp instead of 'select'
Date: Mon, 5 Dec 2016 10:44:32 -0500 (EST)
Message-ID: <alpine.LFD.2.20.1612051039010.1657@knanqh.ubzr>
References: <20161202230451.1639318-1-arnd@arndb.de> <20161203.233945.1757084444220812603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: arnd@arndb.de, felix.manlunas@caviumnetworks.com,
        tglx@linutronix.de, david.daney@cavium.com,
        satananda.burla@caviumnetworks.com, rvatsavayi@caviumnetworks.com,
        sgoutham@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36388 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbcLEPof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 10:44:35 -0500
Received: by mail-io0-f174.google.com with SMTP id m5so464539952ioe.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 07:44:35 -0800 (PST)
In-Reply-To: <20161203.233945.1757084444220812603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Dec 2016, David Miller wrote:

> From: Arnd Bergmann <arnd@arndb.de>
> Date: Sat,  3 Dec 2016 00:04:32 +0100
> 
> > ptp now depends on the optional POSIX_TIMERS setting and fails to build
> > if we select it without that:
> > 
> > warning: (LIQUIDIO_VF && TI_CPTS) selects PTP_1588_CLOCK which has unmet direct dependencies (NET && POSIX_TIMERS)
> > warning: (LIQUIDIO_VF && TI_CPTS) selects PTP_1588_CLOCK which has unmet direct dependencies (NET && POSIX_TIMERS)
> > ERROR: "posix_clock_unregister" [drivers/ptp/ptp.ko] undefined!
> > ERROR: "posix_clock_register" [drivers/ptp/ptp.ko] undefined!
> > ERROR: "pps_unregister_source" [drivers/ptp/ptp.ko] undefined!
> > ERROR: "pps_event" [drivers/ptp/ptp.ko] undefined!
> > ERROR: "pps_register_source" [drivers/ptp/ptp.ko] undefined!
> > 
> > It seems that two patches have collided here, the build failure
> > is a result of the combination. Changing the new option to 'imply'
> > as well fixes it.
> > 
> > Fixes: 111fc64a237f ("liquidio CN23XX: VF registration")
> > Fixes: d1cbfd771ce8 ("ptp_clock: Allow for it to be optional")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Like the kbuild robot, when I apply this it complains about 'imply' being
> an unknown option.
> 
> I guess it worked for you because support for 'imply' exists in the -next
> tree and gets pulled in from somewhere else.

Exact.

> In any event, as-is I cannot apply this.

It should be carried in linux-next for the time being, and suggested as 
a probable "merge resolution" to Linus when submitting your tree for 
merging.  I think that's the best that can be done.


Nicolas
