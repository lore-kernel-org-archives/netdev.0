From: Yonghong Song <yhs@fb.com>
Subject: Re: [lkp-robot] [bpf] 76cdd39f41:
 WARNING:trinity-c0_still_has_locks_held
Date: Mon, 30 Oct 2017 14:57:10 -0700
Message-ID: <c57c939b-c94e-f54d-483a-31723122d965@fb.com>
References: <20171025161827.GD3294@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>, <lkp@01.org>
To: kernel test robot <xiaolong.ye@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46126 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751700AbdJ3V6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:58:03 -0400
In-Reply-To: <20171025161827.GD3294@yexl-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am not able to reproduce the bug with latest net-next.

Thanks Daniel to point it out, looks like your test uses an old-version
unapplied patchset:
https://github.com/0day-ci/linux/commit/76cdd39f4117a6cbd520b5d09993ac87acbdcfd8
which yes, there is a bug to leak the mutext lock and the bug
is fixed in subsequent patch set.

> 
> FYI, we noticed the following commit (built with gcc-4.8):
> 
> commit: 76cdd39f4117a6cbd520b5d09993ac87acbdcfd8 ("bpf: permit multiple bpf attachments for a single perf event")
> url: https://github.com/0day-ci/linux/commits/Yonghong-Song/bpf-permit-multiple-bpf-attachments-for-a-single-perf-tracepoint-event/20171024-080608
> 
> 
> in testcase: boot
> 
> on test machine: qemu-system-x86_64 -enable-kvm -smp 2 -m 512M
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> +----------------+------------+------------+
> |                | 052bd6a4fb | 76cdd39f41 |
> +----------------+------------+------------+
> | boot_successes | 64         | 66         |
> +----------------+------------+------------+
> 
> 
> 
> [   50.247341] WARNING: trinity-c0/3371 still has locks held!
> [main] Random reseed: 4199236289
> [   50.258948] 4.14.0-rc5-01671-g76cdd39 #1 Not tainted
> [   50.260888] ------------------------------------
> [child0:3373] io_getevents (208) returned ENOSYS, marking as inactive.
> [child0:3373] sysfs (139) returned ENOSYS, marking as inactive.
> [   50.273066] 1 lock held by trinity-c0/3371:
> [   50.274247]  #0:  (bpf_event_mutex){....}, at: [<ffffffff811cd617>] perf_event_detach_bpf_prog+0x17/0xd0
> [child0:3373] fanotify_mark (301) returned ENOSYS, marking as inactive.
> *** glibc detected *** /trinity: double free or corruption (out): 0x0000000001d51000 ***
> [   50.288585]
> [   50.288585] stack backtrace:
> [   50.290123] CPU: 1 PID: 3371 Comm: trinity-c0 Not tainted 4.14.0-rc5-01671-g76cdd39 #1
> [   50.292804] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   50.295763] Call Trace:
> [   50.296791]  dump_stack+0xcb/0x13f
> [   50.298244]  do_exit+0xf1f/0x1380
> [   50.299525]  ? syscall_trace_enter+0x3ce/0x490
> [   50.301186]  do_group_exit+0x9d/0x120
> [   50.302531]  SyS_exit_group+0xb/0x10
> [   50.303746]  do_syscall_64+0xa6/0x240
> [   50.305256]  entry_SYSCALL64_slow_path+0x25/0x25
> [   50.306847] RIP: 0033:0x7f60b8dae408
> [   50.307944] RSP: 002b:00007fff020656e8 EFLAGS: 00000206 ORIG_RAX: 00000000000000e7
> [   50.310457] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f60b8dae408
> [   50.312482] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> [   50.314526] RBP: 00007fff020665a0 R08: 00000000000000e7 R09: ffffffffffffffa0
> [   50.316981] R10: 00007fff02065480 R11: 0000000000000206 R12: 0000000000000299
> [   50.319413] R13: 0000000000000059 R14: 00007fff02065d10 R15: 0000000000000002
> ======= Backtrace: =========
> 
> To reproduce:
> 
>          git clone https://github.com/intel/lkp-tests.git
>          cd lkp-tests
>          bin/lkp qemu -k <bzImage> job-script  # job-script is attached in this email
> 
> 
> 
> Thanks,
> Xiaolong
> 
