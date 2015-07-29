From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 3/5] Add calls to translate Always Running Timer (ART)
 to system time
Date: Wed, 29 Jul 2015 10:25:10 +0200
Message-ID: <1438158310.5106.14.camel@tiscali.nl>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
	 <1438044416-15588-4-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438044416-15588-4-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On ma, 2015-07-27 at 17:46 -0700, Christopher Hall wrote:
> --- /dev/null
> +++ b/arch/x86/include/asm/art.h

> +#ifndef CONFIG_X86_ART
> +
> +static inline int setup_art(void)
> +{
> +	return 0;
> +}
> +
> +static inline bool has_art(void)
> +{
> +	return false;
> +}
> +
> +static inline int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art)
> +{
> +	return -ENXIO;
> +}
> +static inline int art_to_realtime64(struct timespec64 *realtime, cycle_t art)
> +{
> +	return -ENXIO;
> +}
> +static inline int art_to_mono64(struct timespec64 *mono, cycle_t art)
> +{
> +	return -ENXIO;
> +}
> +
> +#else
> +
> +extern int setup_art(void);
> +extern bool has_art(void);
> +extern int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art);
> +extern int art_to_realtime64(struct timespec64 *realtime, cycle_t art);
> +extern int art_to_mono64(struct timespec64 *mono, cycle_t art);
> +
> +#endif

> --- /dev/null
> +++ b/arch/x86/kernel/art.c

> +static bool has_art(void)
> +{
> +	return art_present;
> +}
> +EXPORT_SYMBOL(has_art);

This exports a static function. Does that work?

> +static int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art)
> +{
> +	if (!checked_art_to_tsc(&art))
> +		return -ENXIO;
> +	return tsc_to_rawmono64(rawmono, art);
> +}
> +EXPORT_SYMBOL(art_to_rawmono64);
> +
> +static int art_to_realtime64(struct timespec64 *realtime, cycle_t art)
> +{
> +	if (!checked_art_to_tsc(&art))
> +		return -ENXIO;
> +	return tsc_to_realtime64(realtime, art);
> +}
> +EXPORT_SYMBOL(art_to_realtime64);
> +
> +static int art_to_mono64(struct timespec64 *mono, cycle_t art)
> +{
> +	if (!checked_art_to_tsc(&art))
> +		return -ENXIO;
> +	return tsc_to_mono64(mono, art);
> +}
> +EXPORT_SYMBOL(art_to_mono64);

Ditto (three times).

By the way, this series doesn't add users for art_to_mono64() and
art_to_mono64(), right?

Thanks,


Paul Bolle
