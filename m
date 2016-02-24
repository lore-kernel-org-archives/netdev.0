From: Pavel Machek <pavel@ucw.cz>
Subject: custom ioctl-based interface to control LED in networking (was Re:
 [PATCHv2 09/10] rfkill: Userspace control for airplane mode)
Date: Wed, 24 Feb 2016 11:46:11 +0100
Message-ID: <20160224104611.GB31302@amd>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
 <20160223204525.GC16961@amd>
 <1456260914.9910.34.camel@sipsolutions.net>
 <20160223214501.GA22501@amd>
 <1456304509.2050.15.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>, rpurdie@rpsys.net,
	j.anaszewski@samsung.com, linux-leds@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456304509.2050.15.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 2016-02-24 10:01:49, Johannes Berg wrote:
> On Tue, 2016-02-23 at 22:45 +0100, Pavel Machek wrote:
> 
> > Well "the airplane mode" is well defined. It means no intentional
> > transmitting at radio frequencies.
> > 
> > The fact that you are allowed to use WIFI on certain flights does not
> > change anything.
> 
> Nope, not that simple. Pick up any (contemporary) smartphone and watch
> what happens with the airplane mode indicator (the little airplane
> icon) when you enable wifi after enabling airplane mode. It stays
> there.
> 
> Clearly the same logic could then apply to an actual LED (on a system
> that's less size-constrained, e.g. a laptop or tablet.)
> 
> Thus, the display of "in airplane mode" *does* have policy, and clearly
> there's precedent for not disabling the icon or LED when wifi is
> enabled, but the kernel shouldn't really impose that. Now, the kernel
> has a "safe" default which does what you thought was the "well defined"
> airplane mode, but at the same time it's obviously not good enough.

If you want different trigger, implement different trigger. If you
want to indicate all but wifi, implement all but wifi, and then
userspace can select it by writing trigger name. If you want complete
userspace control, fine, but we have standard interface and it is not
ioctl.

> > (Besides, finding all LEDs with given trigger is trivial
> > operation. Besides... there should never be more than one).
> 
> That *might* actually work. But once a tool has detached the trigger
> the information is gone; and tools would have to do that to control the
> LED, making recovery from any kind of error difficult.

If you allow userspace to control the LED, well, then the LED may no
longer display the "airplane mode" status. Debugging "wrong trigger is
set" will certainly be less tricky than figuring out that "airplane
mode trigger" is actually "no trigger" based on some obscure ioctls.

> In any case, I've applied those patches already.

Well, you can still revert them before it becomes ABI. David does
not have to pull from you and Linus does not have to pull from
Linus. Besides, the series really should have been Cc-ed to LED
people, too.

Having custom, ioctl-based interface to control the LED is just too
ugly. (And I did not see it documented, which should be another reason
not to merge it.)  

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
