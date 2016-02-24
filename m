From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v8 5/8] time: Add history to cross timestamp interface
 supporting slower devices
Date: Wed, 24 Feb 2016 15:07:36 -0800
Message-ID: <CALAqxLVAJDK7fSPpCVQYjZfnZDbJ+NT53zPE0uCy_kuwcoNh4w@mail.gmail.com>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com>
	<1456139726-3327-6-git-send-email-christopher.s.hall@intel.com>
	<alpine.DEB.2.11.1602241155340.3670@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>,
	kevin.j.clarke@intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1602241155340.3670@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 24, 2016 at 2:56 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Mon, 22 Feb 2016, Christopher S. Hall wrote:
>> +{
>> +     struct timekeeper *tk = &tk_core.timekeeper;
>> +     bool interp_forward;
>> +     u64 corr_raw, corr_real;
>> +     int ret;
>
> Once more:
>
>         struct timekeeper *tk = &tk_core.timekeeper;
>         u64 corr_raw, corr_real;
>         bool interp_forward;
>         int ret;
>
> Is way simpler to parse fast.

So I just went through and addressed these formatting issues in my tree.

but....

>> @@ -929,6 +1046,12 @@ int get_device_system_crosststamp(int (*get_time_fn)
>>       ktime_t base_real;
>>       s64 nsec_raw;
>>       s64 nsec_real;
>> +     cycles_t cycles;
>> +     cycle_t now;

I just noticed this train-wreck: cycles_t and cycle_t are obnoxiously
different types. (One is an int on some arches and the other is a
u64).

You very much want to use cycle_t here. And I think that goes for the
introduced cycle_between() function.

So I'm fixing that up as well in this patch, but there's a few other
spots in this series too.

Sigh. Going to have to find some time to go through and try to zap
cycles_t in the kernel  because having both is just asking for
trouble.  :P

thanks
-john
