From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v7 5/8] time: Add history to cross timestamp interface
 supporting slower devices
Date: Fri, 19 Feb 2016 09:33:44 -0800
Message-ID: <CALAqxLVr-38tqRt9YFNU+ZV0CJMerKfka-ckw4WFc4uJac_rZw@mail.gmail.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
	<1455308729-6280-6-git-send-email-christopher.s.hall@intel.com>
	<20160218221704.GA26007@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>,
	kevin.j.clarke@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160218221704.GA26007@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 2:17 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Fri, Feb 12, 2016 at 12:25:26PM -0800, Christopher S. Hall wrote:
>>  /**
>>   * get_device_system_crosststamp - Synchronously capture system/device timestamp
>> - * @sync_devicetime: Callback to get simultaneous device time and
>> + * @get_time_fn:     Callback to get simultaneous device time and
>
> Fold this into earlier patch?
>
>>   *   system counter from the device driver
>> + * @history_ref:     Historical reference point used to interpolate system
>> + *   time when counter provided by the driver is before the current interval
>
> KernelDoc says history_ref,
>
>>   * @xtstamp:         Receives simultaneously captured system and device time
>>   *
>>   * Reads a timestamp from a device and correlates it to system time
>> @@ -920,6 +1035,7 @@ int get_device_system_crosststamp(int (*get_time_fn)
>>                                  struct system_counterval_t *sys_counterval,
>>                                  void *ctx),
>>                                 void *ctx,
>> +                               struct system_time_snapshot *history_begin,
>>                                 struct system_device_crosststamp *xtstamp)
>
> ... but parameter is called history_begin.

Yep. I reworked those in my tree when I fixed the earlier issue you pointed out.

https://git.linaro.org/people/john.stultz/linux.git/commitdiff/70aa310cf0a5181e62d910a7854a27c2f927315c
and
https://git.linaro.org/people/john.stultz/linux.git/commitdiff/e61e7d694c220d48959475b0e0a8b3bd991aeb22


Let me know if you see anything else.

thanks
-john
