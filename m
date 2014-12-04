From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: What's the concern about setting irq thread's policy as SCHED_FIFO
Date: Thu, 4 Dec 2014 11:12:12 +0800
Message-ID: <547FD10C.8040900@huawei.com>
References: <547EC4A3.6060408@huawei.com> <547F3F92.2050501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547F3F92.2050501@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/12/4 0:51, Rick Jones wrote:
> On 12/03/2014 12:06 AM, Qin Chuanyu wrote:
>> I am doing network performance test under suse11sp3 and intel 82599 nic,
>> Becasuse the softirq is out of schedule policy's control, so netserver
>> thread couldn't always get 100% cpu usage, then packet dropped in kernel
>> udp socket's receive queue.
>>
>> In order to get a stable result, I did some patch in ixgbe driver and
>> then use irq_thread instead of softirq to handle rx.
>> It seems work well, but irq_thread's SCHED_FIFO schedule policy cause
>> that when the cpu is limited, netserver couldn't work at all.
>
> I cannot speak to any scheduling issues/questions, but can ask if you
> tried binding netserver to a CPU other than the one servicing the
> interrupts via the -T option on the netperf command line:
>
> netperf -T <netperfCPU>,<netserverCPU>  ...
>
> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#index-g_t_002dT_002c-Global-41
>
Yes, I had done this try, the irq_thread and netserver worked well 
without competition after binding them separately.
I also had tried this test case in kernel 3.10, and without binding 
irq_thread and netserver work well separately.

So, the question is:
	3.10:    irq_thread netserver  good
	3.0.93:  irq_thread netserver  bad(compete single cpu)
normal thread in both kernel version is OK.

There must be a schedule policy change lead to this difference.
Could anyone give some hint?

>
> happy benchnmarking,
>
> rick jones
>
>>
>> So I change the irq_thread's schedule policy from SCHED_FIFO to
>> SCHED_NORMAL, then the irq_thread could share the cpu usage with
>> netserver thread.
>>
>> the question is:
>> What's the concrete reason about setting irq thread's policy as
>> SCHED_FIFO?
>> Except the priority affecting the cpu usage, any function would be
>> broken if irq thread change to SCHED_NORMAL?
>>
