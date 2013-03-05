From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Tue, 05 Mar 2013 23:57:44 +0530
Message-ID: <51363920.3040906@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com> <5122551E.1080703@linux.vnet.ibm.com>	<51226B46.9080707@linux.vnet.ibm.com> <CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com> <51226F91.7000108@linux.vnet.ibm.com> <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet.ibm.com> <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-E
 Z8w@mail.gmail.com> <512E7879.20109@linux.vnet.ibm.com> <5130EA6B.6030901@cn.fujitsu.com> <513105DD.8010908@linux.vnet.ibm.com> <51361C71.5060502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Lai Jiangshan <eag0628@gmail.com>,
	Michel Lespinasse <walken@google.com>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	namhyung@kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <51361C71.5060502@cn.fujitsu.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Lai,

On 03/05/2013 09:55 PM, Lai Jiangshan wrote:
> Hi, Srivatsa,
> 
> I'm sorry again, I delayed your works.
>

No, you didn't :-) I have been busy with some internal work lately,
so I haven't been able to go through the recent discussions and
review the new code carefully.. I'll get to it as soon as I can.
 
> I have some thinkings about the way how to get this work done.
> 
> First step: (2~3 patches)
> Use preempt_disable() to implement get_online_cpu_atomic(), and add lockdep for it.
> 
> Second step:
> Conversion patches.
> 
> We can send the patchset of the above steps at first.
> {
> It does not change any behavior of the kernel.
> and it is annotation(instead of direct preempt_diable() without comments sometimes),
> so I expected they can be merged very early.
> }
> 
> Third step:
> After all people confide the conversion patches covered all cases and cpuhotplug site is ready for it,
> we will implement get_online_cpu_atomic() via locks and remove stop_machine() from cpuhotplug.
> 
> Any thought?
> 

That sounds like a good plan. It might involve slightly more churn
than just directly changing the locking scheme, but it is safer.
And the extra churn is anyway limited only to the implementation of
get/put_online_cpus_atomic().. so that should be fine IMHO.

> 
> If I have time, I will help you for the patches of the first step.
> (I was assigned bad job in office-time, I can only do kernel-dev work in night.)
> 
> And for step2, I will write a checklist or spatch-script.
> 

Do look at the conversion already done in this v6 as well. In
addition to that, we will have to account for the new kernel
code that went in recently.

I'll get back to working on the above mentioned aspects soon.

Regards,
Srivatsa S. Bhat

