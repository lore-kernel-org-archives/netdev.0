From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Tue, 26 Feb 2013 20:47:30 +0530
Message-ID: <512CD20A.3020100@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com> <5122551E.1080703@linux.vnet.ibm.com> <51226B46.9080707@linux.vnet.ibm.com> <CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com> <51226F91.7000108@linux.vnet.ibm.com> <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF53gcuEfgM=L8-mPTt4W3GFMte-w6eyO0iv2CobAN68SNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	Michel Lespinasse <walken@google.com>, mingo@kernel.org,
	linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
	rostedt@goodmis.org, rjw@sisk.pl, namhyung@kernel.org,
	tglx@linutronix.de, linux-arm-kernel@lists.infradead.org,
	Lai Jiangshan <laijs@cn.fujitsu.com>, netdev@vger.kernel.org,
	oleg@redhat.com, vincent.guittot@linaro.org, sbw@mit.edu,
	tj@kernel.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <eag0628@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CACvQF53gcuEfgM=L8-mPTt4W3GFMte-w6eyO0iv2CobAN68SNw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/26/2013 07:04 PM, Lai Jiangshan wrote:
> On Tue, Feb 26, 2013 at 3:26 AM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> Hi Lai,
>>
>> On 02/25/2013 09:23 PM, Lai Jiangshan wrote:
>>> Hi, Srivatsa,
>>>
>>> The target of the whole patchset is nice for me.
>>
>> Cool! Thanks :-)
>>
>>> A question: How did you find out the such usages of
>>> "preempt_disable()" and convert them? did all are converted?
>>>
>>
>> Well, I scanned through the source tree for usages which implicitly
>> disabled CPU offline and converted them over.
> 
> How do you scan? could you show the way you scan the source tree.
> I can follow your instructions for double checking.
> 

Its nothing special. I grepped the source tree for anything dealing with
cpu_online_mask or its derivatives and also for functions/constructs that
rely on the cpumasks internally (eg: smp_call_function). Then I audited all
such call-sites and converted them (if needed) accordingly.

>> Its not limited to uses
>> of preempt_disable() alone - even spin_locks, rwlocks, local_irq_disable()
>> etc also help disable CPU offline. So I tried to dig out all such uses
>> and converted them. However, since the merge window is open, a lot of
>> new code is flowing into the tree. So I'll have to rescan the tree to
>> see if there are any more places to convert.
> 
> I remember some code has such assumption:
>     preempt_disable() (or something else)
>     //the code assume that the cpu_online_map can't be changed.
>     preempt_enable()
> 
> It is very hard to find out all such kinds of assumptions and fixes them.
> (I notice your code mainly fixes code around send_xxxx())
> 

The conversion can be carried out using the method I mentioned above.

Regards,
Srivatsa S. Bhat

