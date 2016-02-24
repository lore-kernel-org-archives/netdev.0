From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 5/8] time: Add history to cross timestamp interface
 supporting slower devices
Date: Wed, 24 Feb 2016 11:56:49 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1602241155340.3670@nanos>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com> <1456139726-3327-6-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: richardcochran@gmail.com, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-6-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Feb 2016, Christopher S. Hall wrote:
> +{
> +	struct timekeeper *tk = &tk_core.timekeeper;
> +	bool interp_forward;
> +	u64 corr_raw, corr_real;
> +	int ret;

Once more:

	struct timekeeper *tk = &tk_core.timekeeper;
	u64 corr_raw, corr_real;
	bool interp_forward;
	int ret;

Is way simpler to parse fast.

>  {
>  	struct timekeeper *tk = &tk_core.timekeeper;
> @@ -929,6 +1046,12 @@ int get_device_system_crosststamp(int (*get_time_fn)
>  	ktime_t base_real;
>  	s64 nsec_raw;
>  	s64 nsec_real;
> +	cycles_t cycles;
> +	cycle_t now;
> +	cycle_t interval_start;
> +	unsigned int clock_was_set_seq;
> +	u8 cs_was_changed_seq;
> +	bool do_interp;

Single lines for same types .....

Other than that:

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
