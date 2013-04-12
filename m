From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2 1/1 net] enet: fec: fix fail resume from suspend state
Date: Fri, 12 Apr 2013 10:23:56 -0300
Message-ID: <CAOMZO5A9Tc_n8OGgxxw0ZE9xGOPjsYvyqVZtjWwTRn9as3eKCw@mail.gmail.com>
References: <1364350323-2488-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shawn.guo@linaro.org, lznuaa@gmail.com,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f54.google.com ([209.85.212.54]:42066 "EHLO
	mail-vb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830Ab3DLNX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:23:57 -0400
Received: by mail-vb0-f54.google.com with SMTP id w16so2128180vbf.13
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:23:56 -0700 (PDT)
In-Reply-To: <1364350323-2488-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Frank,

On Tue, Mar 26, 2013 at 11:12 PM, Frank Li <Frank.Li@freescale.com> wrote:
> Without this patch
> 1. boot with nfs (no_console_suspend)
> 2. echo mem >/sys/power/state
> 3. wakeup by wakesource
> 4. print "eth0: tx queue full"

I still have issues with suspend/resume with your patch applied:

$ echo enabled >
/sys/devices/80000000.apb/80040000.apbx/80074000.serial/tty/ttyAMA0/power/wakeup
$ echo mem > /sys/power/state

[   31.577857] PM: Syncing filesystems ... done.
[   31.604332] Freezing user space processes ... (elapsed 0.01 seconds) done.
[   31.622160] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) do.
[   31.642018] Suspending console(s) (use no_console_suspend to debug)
[   31.666914] PM: suspend of devices complete after 12.672 msecs
[   31.671975] PM: late suspend of devices complete after 5.007 msecs
[   31.678542] PM: noirq suspend of devices complete after 6.521 msecs
[   31.682147] PM: noirq resume of devices complete after 3.186 msecs
[   31.687396] PM: early resume of devices complete after 3.464 msecs
[   31.759982] PM: resume of devices complete after 2432.562 msecs

(Then send any char via DUART to wakeup the system)

[   31.802673] Restarting tasks ... done.
[   33.829493] libphy: 800f0000.etherne:00 - Link is Down
[   36.859102] FEC: MDIO read timeout
[   38.889180] FEC: MDIO read timeout

It does not fail 100%: there are times that suspend works just fine.
