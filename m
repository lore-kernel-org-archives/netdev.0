From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Sat, 19 Apr 2008 00:34:30 +0200
Message-ID: <20080418223430.GA13847@elf.ucw.cz>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org> <9BEB490E-DE8A-4018-9696-E5074CC638AC@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9BEB490E-DE8A-4018-9696-E5074CC638AC-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri 2008-04-18 23:07:10, Marcel Holtmann wrote:
> Hi Andrew,
>
>> From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
>>
>> _urb_free is an alias for kfree... making code longer & harder to
>> read. Remove it.
>
> our own URB handling here is broken anyway. It was a bad idea when we did 
> it, but at that time the USB susbsystem was not in that good shape that it 
> is today. So I would say leave this code as it is and concentrate on the 
> new btusb driver, but if it helps anybody I am happy to ACK this one.

It currently corrupts memory (use after free) during suspend, and I'm
trying to get that fixed. It is 90% reproducible.

And yes, fixing clean code is easier.

It could be easily fixed by just not freeing the urbs during
disconnect (introducing very very slow memory leak). Would that be
acceptable?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
