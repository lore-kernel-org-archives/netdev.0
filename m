From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Where Linux 802.11x support needs work
Date: Tue, 25 Jan 2005 18:40:39 -0800
Message-ID: <20050126024039.GA25326@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Williams wrote :
> 
> This list of stuff that should get fixed in Linux wireless grew out of my 
> attempt to put a GUI on top of Linux wireless with NetworkManager 
> (http://people.redhat.com/dcbw/NetworkManager).  This isn't, of course, a 
> demand or anything, and I've been personally slowly fixing stuff up as I 
> come to it (orinoco merge, fixing linux-wlan-ng, small kernel wireless 
> driver patches)

	Yes, I've seen your various contributions for the various
drivers. I'm glad that someone is doing all these little fixes,
because they are needed, and such a job is not gratifying and not well
recognised. I used to do more of that, in the past, when I had more
time, and Pavel did some, but it's not our full time job to work on
Linux.
	I also want to thank you for your work on the NetworkManager,
it's a great piece of work and goes beyond what I had in mind when I
created the API.

> I think the biggest issue here is that the Wireless Extensions API has 
> stagnated a bit, and driver writers have gone off and done their own thing 
> (for example, WPA support) because the WEAPI hasn't shown leadership in 
> this area.  That's fixable, and at this point doesn't seem to be a large 
> amount of work since the main offender here is only WPA.

	You know already that in Linux things happen by pushing
patches around, not by "showing leadership" (whatever that
means). Driver authors will always do their own thing, nobody can
prevent them, and it's actually a good thing as it creates inovation
and the best ideas can then be folded back into the official API. Yes,
I believe in the bottom up approach (cheers).
	Note that API doesn't happen in isolation, you need to make
things happen on both sides of it, and the API feed on the experience
of both sides.
	Because NetworkManager is both useful and standard, it will
show leadership and force driver authors to conform to its
requirements. If a driver is broken with NetworkManager, users will
bug the author until it's fixed. I've seen that happening with various
other tools (unfortunately, my wtools are too permissive).

> o  Quality values vary wildly or are absent
>      - Average and max quality levels for almost all drivers are
>         artificial and don't come from the the card in any way

	Those can't come from the hardware, they may only come from
the spec, when available.
	The idea with "average" and "max" would be that application
authors would feed back driver authors as to what to
use. Unfortunately, it did not happen, especially that apps decided to
ignore them.

> o  Frequency values vary wildly from iw_get_range
>   1) prism54 uses completely different exponent values than airo
>   2) airo, atmel, orinoco are the same

	Nobody in their right mind would use iwfreq for anything, it's
just used to go across the kernel interface. Once in userspace, just
use the iw_freq2float() and iw_float2freq() to convert to double, and
then it's all normalised.
	If you need it, I can donate you those two functions under LGPL.

> o  Not all drivers have correct netlink support, if they even have it

	Note that netlink make only sense in Managed mode, it does not
make sense in Ad-Hoc or Master mode. That make things a bit more messy
to implement.
	In the interim, for driver that don't support netlink you can
check the value of the AP address.

> o  Not all drivers support wirless scanning
>   1) orinoco driver mainly, support is upstream and is being slowly
>      merged into the kernel driver

	Just for your info, I was the one who originally authored the
Scanning patch for the Orinoco driver (based on other patches). After
that many people improved on it.

> o  Ad-Hoc mode support is quite flaky or absent from most drivers

	Low priority for most vendors, firwmares are only lightly tested.

> o  WPA support is lacking or just in-progress, needs much help

	Preliminary patch is on my web page :
http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html#wext
	Jouni is the main author, as he is doing the supplicant. He
told me that he want to make a few additional changes. WPA is quite
complex and therefore I would prefer to make sure it's right.


	Note that various other people have their own todo list. Jeff
also has things he has in minds. I have (few) patches on my web
pages. Driver authors also have their wishes.
	One of the big item not mentionned by you is the in-kernel
802.11 stack (native frames and management). If done right, I guess it
would mostly be transparent to you...

	Have fun...

	Jean
