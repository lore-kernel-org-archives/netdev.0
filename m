From: Stefan Rompf <srompf@isg.de>
Subject: Re: 2.5.50 BUG_TRAP on !dev->deadbeaf, and oopses
Date: Sun, 01 Dec 2002 13:45:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DEA0452.B1F15BFD@isg.de>
References: <3DE9290A.7070502@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

David Brownell wrote:

>    KERNEL: assertion (!dev->deadbeaf) failed at net/core/dev.c(2544)
> 
> I think there's another bug, beyond the obvious speling erorz.  Namely,
> that "deadbeaf" is only set after that BUG_TRAP, or on one error path.
> The assertion prevents hotpluggable network drivers from unregistering
> when the hardware goes away ... which is a regression.

actually, the assertion is triggered when someone tries to unregister a
netdevice twice, and that's also why you get

>    unregister_netdevice: device /dfd74058 never was registered

>From a short browsing through usb.c I don't see a similiar bug catcher
in usb_device_remove(), so have a look if the USB subsystem itself
removes a unplugged device
twice for some reason.

Stefan
