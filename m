From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/9] atm: propagate atm_dev signal carrier to
 LOWER_UP of netdevice
Date: Wed, 07 Jul 2010 15:07:41 -0700 (PDT)
Message-ID: <20100707.150741.267964636.davem@davemloft.net>
References: <1278492636-11094-1-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
To: karl@hiramoto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751809Ab0GGWH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 18:07:27 -0400
In-Reply-To: <1278492636-11094-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Hiramoto <karl@hiramoto.org>
Date: Wed,  7 Jul 2010 10:50:27 +0200

> Changes from v2:
>  * use atomic instead of blocking notifier
>  * use read_lock_irq() instead of read_lock() in atm/br2684
>  * clean up comments
>  * remove unused variable.  I feel really bad about missing that last time.
>  
> Changes from v1:
> Use atm_dev notifier chain  instead of callback function pointer in struct vcc.
> In drivers/usb/atm call atm_dev_signal_change().
> 
> In userspace it's helpful to know if a network device has a carrier signal.
> Often it is monitored via netlink.  This patchset allows a way for the
> struct atm_dev drivers to pass carrier on/off to the netdevice.
> 
> For DSL, carrier is on when the line has reached showtime state.
> 
> Currently this patchset only propagates the changes to br2684 vccs,
> as this is the only type of hardware I have to test.
> 
> If you prefer git you can pull from:
> git://github.com/karlhiramoto/linux-2.6.git atm-v3

I think the locking still needs another tweak.

By using read_lock_irq() you are assuming that you are invoked
from a context where irqs are disabled.

That's not necessarily the case, in fact some of your notifier call
sites in the drivers are in interrupt handlers where interrupts may or
may not be disabled.

So you'll likely need to use read_lock_irqsave() and read_lock_irqrestore().

Next, please format comments:

/* Like
 * this.
 */

Thanks.
