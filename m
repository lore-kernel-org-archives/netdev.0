From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 9750] [patch 2.6.25 v2] dev: avoid a race that triggers
 assertion failure
Date: Tue, 12 Feb 2008 23:10:35 -0800 (PST)
Message-ID: <20080212.231035.10816823.davem@davemloft.net>
References: <127401.85852.qm@web52006.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: mattilinnanvuori@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755034AbYBMHKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 02:10:04 -0500
In-Reply-To: <127401.85852.qm@web52006.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Date: Tue, 12 Feb 2008 23:06:41 -0800 (PST)

> There is a race in Linux kernel file net/core/dev.c, function dev_close.
> The function calls function dev_deactivate, which calls function
> dev_watchdog_down that deletes the watchdog timer. However, after that, a
> driver can call netif_carrier_ok, which calls function
> __netdev_watchdog_up that can add the watchdog timer again. Function
> unregister_netdevice calls function dev_shutdown that traps the bug
> !timer_pending(&dev->watchdog_timer). Moving dev_deactivate after
> netif_running() has been cleared prevents function netif_carrier_on
> from calling __netdev_watchdog_up and adding the watchdog timer again.
> 
> Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Patch applied, thanks.
