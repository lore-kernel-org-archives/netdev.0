From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [RFC 7/7] net: don't check for active hrtimer after adding it
Date: Wed, 9 Jul 2014 16:14:43 +0530
Message-ID: <CAKohpomdxB7ui4WQTWfJva9YYYqcfs6cabsC+SyYijdRUViT_g@mail.gmail.com>
References: <cover.1404888801.git.viresh.kumar@linaro.org>
	<a8994b5dda7599c0d8ce9f66aef40b8587acf691.1404888801.git.viresh.kumar@linaro.org>
	<53BD1A56.7000902@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>,
	"fweisbec@gmail.com" <fweisbec@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"preeti@linux.vnet.ibm.com" <preeti@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arvind Chauhan <Arvind.Chauhan@arm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Chris Redpath <Chris.Redpath@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53BD1A56.7000902@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chris,

On 9 July 2014 16:02, Chris Redpath <Chris.Redpath@arm.com> wrote:

>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index fc17a9d..f911acd 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -2186,8 +2186,6 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t
>> spin_until)
>>                 do {
>>                         set_current_state(TASK_INTERRUPTIBLE);
>>                         hrtimer_start_expires(&t.timer, HRTIMER_MODE_ABS);
>> -                       if (!hrtimer_active(&t.timer))
>> -                               t.task = NULL;
>>
>>                         if (likely(t.task))
>>                                 schedule();
>
>
> I think this if condition can also be removed. hrtimer_init_sleeper copies
> the supplied task_struct * to the timer, which in this case is 'current'.
> The check is likely to be there in case of !active case you removed.

Yeah, it looks like we can get rid of this. Also,

        } while (t.task && pkt_dev->running && !signal_pending(current));

is present in the closing "}" of do-while loop and probably we
don't need to check t.task here as well.

And this review comment applies to patch 2/7 as well:
hrtimer: don't check for active hrtimer after adding it

I would still wait for somebody to prove us wrong :), and will resend
it next week only.

Thanks.
