From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 09:51:38 -0400
Message-ID: <4377616b-1d58-6e33-969e-61070039094e@tycho.nsa.gov>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov>
 <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
 <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
 <CAM_iQpUHoJP6b+qj6CEq7TjXWKuhZpAVGv-MuXGx9D7fUNGTxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nsa.gov ([8.44.101.9]:49929 "EHLO emsm-gh1-uea11.nsa.gov"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755244AbcJUNtp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 09:49:45 -0400
In-Reply-To: <CAM_iQpUHoJP6b+qj6CEq7TjXWKuhZpAVGv-MuXGx9D7fUNGTxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2016 12:47 AM, Cong Wang wrote:
> On Thu, Oct 20, 2016 at 4:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Since you want to test SELinux anyway, please test the attached one.
>>
> 
> Finally my kernel config is friendly to SELinux, and now there are several
> tests fails:
> 
> 
> Test Summary Report
> -------------------
> sysctl/test           (Wstat: 0 Tests: 4 Failed: 2)
>   Failed tests:  1-2
> mmap/test             (Wstat: 0 Tests: 44 Failed: 2)
>   Failed tests:  20, 26
> overlay/test          (Wstat: 65280 Tests: 0 Failed: 0)
>   Non-zero exit status: 255
>   Parse errors: Bad plan.  You planned 121 tests but ran 0.
> Files=44, Tests=306, 47 wallclock secs ( 0.23 usr  0.30 sys +  1.00
> cusr  7.35 csys =  8.88 CPU)
> Result: FAIL
> 
> Seems not related to my patch?

Probably kernel config related.  All tests pass for me on rawhide.
Kernel config?

> And, there is a kernel warning which is totally unrelated to my code:
> 
> 
> [  136.788836] ------------[ cut here ]------------
> [  136.793046] WARNING: CPU: 1 PID: 1345 at fs/locks.c:615
> locks_unlink_lock_ctx+0xc7/0xcc
> [  136.799829] CPU: 1 PID: 1345 Comm: test_lease Not tainted 4.8.0+ #271
> [  136.803814] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  136.803814]  ffffc900036bfd38 ffffffff8152c08e 0000000000000000
> 0000000000000000
> [  136.803814]  ffffc900036bfd78 ffffffff810841c0 00000267036bfc88
> ffff8800db2371e8
> [  136.803814]  ffff8800db26f4c0 ffffc900036bfe00 ffffc900036bfe00
> ffff8800db239240
> [  136.803814] Call Trace:
> [  136.803814]  [<ffffffff8152c08e>] dump_stack+0x67/0x90
> [  136.803814]  [<ffffffff810841c0>] __warn+0xbd/0xd8
> [  136.803814]  [<ffffffff81084297>] warn_slowpath_null+0x1d/0x1f
> [  136.803814]  [<ffffffff8121b9cb>] locks_unlink_lock_ctx+0xc7/0xcc
> [  136.803814]  [<ffffffff8121bd9e>] locks_delete_lock_ctx+0x17/0x3a
> [  136.803814]  [<ffffffff8121be71>] lease_modify+0xb0/0xb9
> [  136.803814]  [<ffffffff8121e868>] locks_remove_file+0x93/0xbd
> [  136.803814]  [<ffffffff811d903d>] __fput+0xd0/0x19b
> [  136.803814]  [<ffffffff811d913e>] ____fput+0xe/0x10
> [  136.803814]  [<ffffffff8109ff86>] task_work_run+0x6c/0x97
> [  136.803814]  [<ffffffff8100188a>] prepare_exit_to_usermode+0xb0/0xcc
> [  136.803814]  [<ffffffff81001a04>] syscall_return_slowpath+0x15e/0x1c2
> [  136.803814]  [<ffffffff81001ad7>] do_syscall_64+0x6f/0x76
> [  136.803814]  [<ffffffff81b22424>] entry_SYSCALL64_slow_path+0x25/0x25
> [  138.538370] ---[ end trace 90914a16bd3272b8 ]---

Don't see this on current kernels (e.g. 4.9-rc1).
