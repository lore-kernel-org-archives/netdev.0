From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Mon, 27 Jul 2015 20:44:06 -0700
Message-ID: <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
	<1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2015 at 5:46 PM, Christopher Hall
<christopher.s.hall@intel.com> wrote:
> * counter_to_rawmono64
> * counter_to_mono64
> * counter_to_realtime64
>
> Enables drivers to translate a captured system clock counter to system
> time. This is useful for network and audio devices that capture timestamps
> in terms of both the system clock and device clock.

Huh.  So for counter_to_realtime64 & mono64, this seems to ignore the
fact that the multiplier is constantly adjusted and corrected. So that
calling the function twice with the same counter value may result in
different returned values.

I've not yet groked the whole patchset, but it seems like there needs
to be some mechanism that ensures the counter value is captured and
used in the same (or at least close) interval that the timekeeper data
is valid for.

thanks
-john
