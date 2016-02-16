From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v7 3/8] time: Remove duplicated code in
 ktime_get_raw_and_real()
Date: Tue, 16 Feb 2016 08:52:10 +0100
Message-ID: <20160216075210.GA2461@localhost.localdomain>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <1455308729-6280-4-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455308729-6280-4-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 12:25:24PM -0800, Christopher S. Hall wrote:
> The code in ktime_get_snapshot() is a superset of the code in
> ktime_get_raw_and_real() code. Further, ktime_get_raw_and_real() is
> called only by the PPS code, pps_get_ts(). Consolidate the
> pps_get_ts() code into a single function calling ktime_get_snapshot()
> and eliminate ktime_get_raw_and_real(). A side effect of this is that
> the raw and real results of pps_get_ts() correspond to exactly the
> same clock cycle. Previously these values represented separate reads
> of the system clock.

Nice improvement.

> @@ -888,6 +888,8 @@ void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
>  	s64 nsec_real;
>  	cycle_t now;
>  
> +	WARN_ON(timekeeping_suspended);
...
> -	WARN_ON_ONCE(timekeeping_suspended);

Is this change intentional?

Thanks,
Richard
