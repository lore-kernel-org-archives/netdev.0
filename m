From: David Brownell <david-b@pacbell.net>
Subject: Re: 2.5.50 BUG_TRAP on !dev->deadbeaf, and oopses
Date: Mon, 02 Dec 2002 10:44:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DEBA9F5.6000606@pacbell.net>
References: <3DE9290A.7070502@pacbell.net> <3DEA0452.B1F15BFD@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stefan,

>>   KERNEL: assertion (!dev->deadbeaf) failed at net/core/dev.c(2544)
>>
>>I think there's another bug, beyond the obvious speling erorz.  Namely,
>>that "deadbeaf" is only set after that BUG_TRAP, or on one error path.
>>The assertion prevents hotpluggable network drivers from unregistering
>>when the hardware goes away ... which is a regression.
> 
> 
> actually, the assertion is triggered when someone tries to unregister a
> netdevice twice, and that's also why you get

Then why will grep of all kernel files not turn up other places where
'deadbeaf' gets set?  There's strange stuff going on here regardless
(as well as speling issue), which looks pretty buglike.

Plus: this kind of bugcatch should use magic numbers, or maybe zero.
Assuming "any nonzero value is valid", like this assertion does, is
clearly going to fail for any of the class of bugs highlighted by
slab poisoning.  (0xa5a5a5a5 gets accepted as valid...)


>>   unregister_netdevice: device /dfd74058 never was registered
> 
> 
> From a short browsing through usb.c I don't see a similiar bug catcher
> in usb_device_remove(), so have a look if the USB subsystem itself
> removes a unplugged device twice for some reason.

At least one failure path also involves "rmmod" of the network
drivers, where the device hardware is still around; so that code
would not always be called.

I wouldn't rule out problems in the relevant usbcore/sysfs bits,
even now that they seem to have stabilized again (and yes, I was
wondering about multiple disconnects too), but all that deadbeaf
logic still looks fishy to me.

- Dave
