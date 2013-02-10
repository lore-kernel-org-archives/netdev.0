From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 09/45] smp, cpu hotplug: Fix smp_call_function_*()
 to prevent CPU offline properly
Date: Mon, 11 Feb 2013 01:29:15 +0530
Message-ID: <5117FC13.1030002@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073508.13822.12784.stgit@srivatsabhat.in.ibm.com> <20130209000717.GP2666@linux.vnet.ibm.com> <5117F7E9.7070906@linux.vnet.ibm.com> <20130210195639.GL2666@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, rusty@rustcorp.com.au, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130210195639.GL2666@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/2013 01:26 AM, Paul E. McKenney wrote:
> On Mon, Feb 11, 2013 at 01:11:29AM +0530, Srivatsa S. Bhat wrote:
>> On 02/09/2013 05:37 AM, Paul E. McKenney wrote:
>>> On Tue, Jan 22, 2013 at 01:05:10PM +0530, Srivatsa S. Bhat wrote:
>>>> Once stop_machine() is gone from the CPU offline path, we won't be able to
>>>> depend on preempt_disable() to prevent CPUs from going offline from under us.
>>>>
>>>> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
>>>> while invoking from atomic context.
>>>>
>>>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>>>
>>> Would it make sense for get_online_cpus_atomic() to return the current
>>> CPU number?
>>
>> Hmm, I'm not so sure. I tried to model it after get_online_cpus(), which doesn't
>> return anything (for other reasons, of course..)
>>
>> Moreover, a function name like *_cpu_* returning the CPU number would be intuitive.
>> But a name such as *_cpus_* (plural) returning a CPU number might appear confusing..
>>
>> And also I don't think it'll make a huge improvement in the callers.. (We might
>> be better off avoiding an smp_processor_id() if possible, since this function could
>> be called in very hot paths).. So I don't see a strong case for returning the
>> CPU number. But let me know if you think it'll still be worth it for some reason...
> 
> I just noted a lot of two-line code sequences in your patch that would be
> one line if the CPU number was returned.

Ah, in that case, I'll reconsider your suggestion while working on the next version.
Thanks!

Regards,
Srivatsa S. Bhat

>  But I don't feel strongly about
> it, so if people are OK with the current version, no problem.
> 
> 							Thanx, Paul
> 
