From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: [PATCH] bpf: convert hashtab lock to raw lock
Date: Mon, 02 Nov 2015 09:09:03 -0800
Message-ID: <563798AF.7000505@linaro.org>
References: <1446243386-26582-1-git-send-email-yang.shi@linaro.org> <20151031000356.GA28070@Alexeis-MacBook-Pro.local> <20151031094736.494427d7@grimm.local.home> <20151101225620.GA28272@Alexeis-MacBook-Pro.local> <alpine.DEB.2.11.1511020959030.4032@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33269 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbKBRJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:09:05 -0500
Received: by pabfh17 with SMTP id fh17so29886412pab.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 09:09:05 -0800 (PST)
In-Reply-To: <alpine.DEB.2.11.1511020959030.4032@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/2015 12:59 AM, Thomas Gleixner wrote:
> On Sun, 1 Nov 2015, Alexei Starovoitov wrote:
>> On Sat, Oct 31, 2015 at 09:47:36AM -0400, Steven Rostedt wrote:
>>> On Fri, 30 Oct 2015 17:03:58 -0700
>>> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>>
>>>> On Fri, Oct 30, 2015 at 03:16:26PM -0700, Yang Shi wrote:
>>>>> When running bpf samples on rt kernel, it reports the below warning:
>>>>>
>>>>> BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:917
>>>>> in_atomic(): 1, irqs_disabled(): 128, pid: 477, name: ping
>>>>> Preemption disabled at:[<ffff80000017db58>] kprobe_perf_func+0x30/0x228
>>>> ...
>>>>> diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
>>>>> index 83c209d..972b76b 100644
>>>>> --- a/kernel/bpf/hashtab.c
>>>>> +++ b/kernel/bpf/hashtab.c
>>>>> @@ -17,7 +17,7 @@
>>>>>   struct bpf_htab {
>>>>>   	struct bpf_map map;
>>>>>   	struct hlist_head *buckets;
>>>>> -	spinlock_t lock;
>>>>> +	raw_spinlock_t lock;
>>>>
>>>> How do we address such things in general?
>>>> I bet there are tons of places around the kernel that
>>>> call spin_lock from atomic.
>>>> I'd hate to lose the benefits of lockdep of non-raw spin_lock
>>>> just to make rt happy.
>>>
>>> You wont lose any benefits of lockdep. Lockdep still checks
>>> raw_spin_lock(). The only difference between raw_spin_lock and
>>> spin_lock is that in -rt spin_lock turns into an rt_mutex() and
>>> raw_spin_lock stays a spin lock.
>>
>> I see. The patch makes sense then.
>> Would be good to document this peculiarity of spin_lock.
>
> I'm working on a document.

Thanks Steven and Thomas for your elaboration and comment.

Yang

>
> Thanks,
>
> 	tglx
>
