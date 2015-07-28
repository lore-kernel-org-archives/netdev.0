From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 3/5] Add calls to translate Always Running Timer (ART) to
 system time
Date: Mon, 27 Jul 2015 21:11:28 -0700
Message-ID: <CALAqxLXPbVZr0aXceM6bFHd3xu=4W-DinQL8yMMsVYEecPSeHw@mail.gmail.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
	<1438044416-15588-4-git-send-email-christopher.s.hall@intel.com>
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
In-Reply-To: <1438044416-15588-4-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2015 at 5:46 PM, Christopher Hall
<christopher.s.hall@intel.com> wrote:
> +static bool checked_art_to_tsc(cycle_t *tsc)
> +{
> +       if (!has_art())
> +               return false;
> +       *tsc = art_to_tsc(*tsc);
> +       return true;
> +}
> +
> +static int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art)
> +{
> +       if (!checked_art_to_tsc(&art))
> +               return -ENXIO;
> +       return tsc_to_rawmono64(rawmono, art);
> +}
> +EXPORT_SYMBOL(art_to_rawmono64);

This all seems to assume the TSC is the current clocksource, which it
may not be if the user has overridden it.

If instead there were a counter_to_rawmono64() which took the counter
value and maybe the name of the clocksource (if the strncmp is
affordable for your use), it might be easier for the core to provide
an error if the current timekeeping clocksource isn't the one the
counter value is based on. This would also allow the tsc_to_*()
midlayers to be dropped (since they don't seem to do much).

thanks
-john
