From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode
Date: Wed, 24 Feb 2016 10:01:49 +0100
Message-ID: <1456304509.2050.15.camel@sipsolutions.net>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
	 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
	 <20160223204525.GC16961@amd> <1456260914.9910.34.camel@sipsolutions.net>
	 <20160223214501.GA22501@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160223214501.GA22501@amd>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-02-23 at 22:45 +0100, Pavel Machek wrote:

> Well "the airplane mode" is well defined. It means no intentional
> transmitting at radio frequencies.
> 
> The fact that you are allowed to use WIFI on certain flights does not
> change anything.

Nope, not that simple. Pick up any (contemporary) smartphone and watch
what happens with the airplane mode indicator (the little airplane
icon) when you enable wifi after enabling airplane mode. It stays
there.

Clearly the same logic could then apply to an actual LED (on a system
that's less size-constrained, e.g. a laptop or tablet.)

Thus, the display of "in airplane mode" *does* have policy, and clearly
there's precedent for not disabling the icon or LED when wifi is
enabled, but the kernel shouldn't really impose that. Now, the kernel
has a "safe" default which does what you thought was the "well defined"
airplane mode, but at the same time it's obviously not good enough.

And evidently, the Asus system that this was originally proposed for
has such an LED.

> I see that "airplane mode" trigger might be a tiny bit
> useful... dunno, for a LED near the airplane mode switch, when vendor
> replaced hardware toggle with a key. But policy should have nothing
> to do with that. If you argue additional "policy daemon" is needed
> for that... forget it, that's overdesigned.

See above.

> (Besides, finding all LEDs with given trigger is trivial
> operation. Besides... there should never be more than one).

That *might* actually work. But once a tool has detached the trigger
the information is gone; and tools would have to do that to control the
LED, making recovery from any kind of error difficult.

In any case, I've applied those patches already.

As far as the LED subsystem is concerned, all of this is just another
trigger anyway.

johannes
