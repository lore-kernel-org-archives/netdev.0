From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v6 0/9] Patchset enabling hardware based cross-timestamps
 for next gen Intel platforms
Date: Thu, 14 Jan 2016 16:49:24 -0800
Message-ID: <CALAqxLUJLu=0A1CsyMywE0GNjTmYrM5Z1SHJp=ahLkn_XLWsdQ@mail.gmail.com>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 4:12 AM, Christopher S. Hall
<christopher.s.hall@intel.com> wrote:
> Modern Intel hardware adds an Always Running Timer (ART) that allows the
> network and audio device clocks to precisely cross timestamp the device
> clock with the system clock. This allows a precise correlation of the
> device time and system time.
>
> This patchset adds interfaces to the timekeeping code allowing drivers
> to translate ART time to system time.

So thanks again for sending this out. Instead of sending you a bunch
of nitpicky changes as I've done in the past, I figured I'd try to
more directly help out and try to rework some of the patches to be
more to my own liking.

I've pushed them here:
   https://git.linaro.org/people/john.stultz/linux.git dev/xtimestamp

My main changes have been:
* Reordered the patches, putting all the timekeeping core changes
first, then the usage of those interfaces last.

* Implemented Richard's suggestion to drop one of the helper
structures that didn't provide much value

* Moved structures defined in clocksource.h but only used in
timekeeping.h to timekeeping.h

* Fixed a few build issues I caught (as well as some of the ones
kbuild bot found)

* Reworked the tsc logic to avoid 64bit divisions (which don't build
on 32bit systems)

I still have not:
* Done *any* testing at all with this. Please verify I didn't break anything. :)

* Fixed the 64bit div on 32bit systems build issue in
get_device_system_crosststamp()/adjust_historical_crosststamp()

* Done another review/edit pass on the commit messages, as they've
gotten a bit long (I know, I know.. "be verbose" I said!), but they
can probably be tweaked to be better and more contextual to the
patches.

Still on the fence:
* Probably should zap the correlated_cs structure or move it to tsc.h,
as mentioned in my other email

Anyway, I'll let you take a look at this and feel free to integrate
and adapt these ideas as you please into your patchset. Look forward
to your next revision!

thanks
-john
