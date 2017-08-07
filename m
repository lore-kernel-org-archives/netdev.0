From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v4 1/2] bpf: add support for sys_enter_* and
 sys_exit_* tracepoints
Date: Mon, 7 Aug 2017 08:51:09 -1000
Message-ID: <9e28069f-c127-5596-c327-01a09f498a51@fb.com>
References: <20170804230010.2792119-1-yhs@fb.com>
 <20170804230010.2792119-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: Yonghong Song <yhs@fb.com>, <peterz@infradead.org>,
        <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34719 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751429AbdHGSvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:51:46 -0400
In-Reply-To: <20170804230010.2792119-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/4/17 1:00 PM, Yonghong Song wrote:
> Currently, bpf programs cannot be attached to sys_enter_* and sys_exit_*
> style tracepoints. The iovisor/bcc issue #748
> (https://github.com/iovisor/bcc/issues/748) documents this issue.
> For example, if you try to attach a bpf program to tracepoints
> syscalls/sys_enter_newfstat, you will get the following error:
>    # ./tools/trace.py t:syscalls:sys_enter_newfstat
>    Ioctl(PERF_EVENT_IOC_SET_BPF): Invalid argument
>    Failed to attach BPF to tracepoint
>
> The main reason is that syscalls/sys_enter_* and syscalls/sys_exit_*
> tracepoints are treated differently from other tracepoints and there
> is no bpf hook to it.
>
> This patch adds bpf support for these syscalls tracepoints by
>   . permitting bpf attachment in ioctl PERF_EVENT_IOC_SET_BPF
>   . calling bpf programs in perf_syscall_enter and perf_syscall_exit
>
> The legality of bpf program ctx access is also checked.
> Function trace_event_get_offsets returns correct max offset for each
> specific syscall tracepoint, which is compared against the maximum offset
> access in bpf program.
>
> Signed-off-by: Yonghong Song <yhs@fb.com>

lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
