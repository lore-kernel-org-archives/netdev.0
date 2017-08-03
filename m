From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next v2 1/2] bpf: add support for sys_enter_* and
 sys_exit_* tracepoints
Date: Thu, 3 Aug 2017 08:22:51 -0700
Message-ID: <28b9718b-0677-cc23-4c6f-c21169e38c90@fb.com>
References: <20170803052828.2303723-1-yhs@fb.com>
 <20170803052828.2303723-2-yhs@fb.com>
 <20170803080831.6molm6xv6wngcy7l@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>, Steven Rostedt <rostedt@goodmis.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36566 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751352AbdHCPXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:23:43 -0400
In-Reply-To: <20170803080831.6molm6xv6wngcy7l@hirez.programming.kicks-ass.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/3/17 1:08 AM, Peter Zijlstra wrote:
> On Wed, Aug 02, 2017 at 10:28:27PM -0700, Yonghong Song wrote:
>> Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
>> style tracepoints. The iovisor/bcc issue #748
>> (https://github.com/iovisor/bcc/issues/748) documents this issue.
>> For example, if you try to attach a bpf program to tracepoints
>> syscalls/sys_enter_newfstat, you will get the following error:
>>     # ./tools/trace.py t:syscalls:sys_enter_newfstat
>>     Ioctl(PERF_EVENT_IOC_SET_BPF): Invalid argument
>>     Failed to attach BPF to tracepoint
>>
>> The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
>> tracepoints are treated differently from other tracepoints and there
>> is no bpf hook to it.
>>
>> This patch adds bpf support for these syscalls tracepoints by
>>    . permitting bpf attachment in ioctl PERF_EVENT_IOC_SET_BPF
>>    . calling bpf programs in perf_syscall_enter and perf_syscall_exit
>>
>> Signed-off-by: Yonghong Song <yhs@fb.com>
> 
> Ack for the perf bits, but you should've Cc'ed steve too I suppose.

Thanks, Peter. This is first time I posted for tracing related changes.
Will for sure remember this next time.

There is a build error:
======
    kernel/events/core.c: In function 'perf_event_set_bpf_prog':
 >> kernel/events/core.c:8073:18: error: implicit declaration of 
function 'is_syscall_trace_event' [-Werror=implicit-function-declaration]
      is_syscall_tp = is_syscall_trace_event(event->tp_event);
======

Will address this and send another patch soon.
