From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Fri, 29 Aug 2014 12:17:52 -0400
Message-ID: <5400A7B0.3060304@gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	trinity@vger.kernel.org, Dave Jones <davej@redhat.com>
To: Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:33580 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbaH2QR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 12:17:56 -0400
In-Reply-To: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2014 11:26 AM, Tommi Rantala wrote:
> Hi,
> 
> Was fuzzing Linus v3.17-rc2-89-g59753a8 with Trinity as the root user
> in qemu, when I hit the following assertion failures.
> 
> Tommi
> 
> 
> [init] Started watchdog process, PID is 4841
> [main] Main thread is alive.
> [   77.229699] sctp: [Deprecated]: trinity-main (pid 4842) Use of int
> in max_burst socket option deprecated.
> [   77.229699] Use struct sctp_assoc_value instead
> [   77.297196] RTNL: assertion failed at net/ipv6/addrconf.c (1699)
> [   77.298080] CPU: 0 PID: 4842 Comm: trinity-main Not tainted 3.17.0-rc2+ #30
> [   77.299039] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   77.299789]  ffff88003d76a618 ffff880026133c50 ffffffff8238ba79
> ffff880037c84520
> [   77.300829]  ffff880026133c90 ffffffff820bd52b 0000000000000000
> ffffffff82d86c40
> [   77.301869]  0000000000000000 00000000f76fd1e1 ffff8800382d8000
> ffff8800382d8220
> [   77.302906] Call Trace:
> [   77.303246]  [<ffffffff8238ba79>] dump_stack+0x4d/0x66
> [   77.303928]  [<ffffffff820bd52b>] addrconf_join_solict+0x4b/0xb0
> [   77.304731]  [<ffffffff820b031b>] ipv6_dev_ac_inc+0x2bb/0x330
> [   77.305498]  [<ffffffff820b0060>] ? ac6_seq_start+0x260/0x260
> [   77.306257]  [<ffffffff820b05fe>] ipv6_sock_ac_join+0x26e/0x360
> [   77.307046]  [<ffffffff820b0429>] ? ipv6_sock_ac_join+0x99/0x360
> [   77.307798]  [<ffffffff820cdd60>] do_ipv6_setsockopt.isra.5+0xa70/0xf20
> [   77.308570]  [<ffffffff8117097d>] ? sched_clock_local+0x1d/0x80
> [   77.309260]  [<ffffffff810a8a27>] ? kvm_clock_read+0x27/0x40
> [   77.309915]  [<ffffffff810736d9>] ? sched_clock+0x9/0x10
> [   77.310537]  [<ffffffff815afff8>] ? sock_has_perm+0x168/0x1e0
> [   77.311204]  [<ffffffff81170bb8>] ? sched_clock_cpu+0xa8/0xf0
> [   77.311866]  [<ffffffff81170d1b>] ? local_clock+0x1b/0x30
> [   77.312501]  [<ffffffff811872cd>] ? lock_release_holdtime+0x1d/0x170
> [   77.313241]  [<ffffffff815b0010>] ? sock_has_perm+0x180/0x1e0
> [   77.313905]  [<ffffffff815afe90>] ?
> selinux_msg_queue_alloc_security+0xa0/0xa0
> [   77.314746]  [<ffffffff820ce263>] ipv6_setsockopt+0x53/0xb0
> [   77.315397]  [<ffffffff820d3135>] udpv6_setsockopt+0x25/0x30
> [   77.316058]  [<ffffffff81f9930f>] sock_common_setsockopt+0xf/0x20
> [   77.316764]  [<ffffffff81f9305e>] SyS_setsockopt+0x8e/0xd0
> [   77.317406]  [<ffffffff823a47e9>] system_call_fastpath+0x16/0x1b
> [main] 375 sockets created based on info from socket cachefile.
> [main] Generating file descriptors
> [main] Added 129 filenames from /dev
> [main] Added 44048 filenames from /proc
> [main] Added 18192 filenames from /sys
> [main] Enabled 9 fd providers.
> [watchdog] Watchdog is alive. (pid:4841)
> [child3:4846] finit_module (313) returned ENOSYS, marking as inactive.
> [child1:4844] kcmp (312) returned ENOSYS, marking as inactive.
> [child2:4845] uselib (134) returned ENOSYS, marking as inactive.
> [child1:4844] nfsservctl (180) returned ENOSYS, marking as inactive.
> [child2:4845] delete_module (129:[32BIT]) returned ENOSYS, marking as inactive.
> [child2:4845] init_module (175) returned ENOSYS, marking as inactive.
> [   84.126609] trinity-c7: vm86 mode not supported on 64 bit kernel
> [child7:4850] vm86 (166:[32BIT]) returned ENOSYS, marking as inactive.
> [main] Bailing main loop because ctrl-c.
> [   84.345840] RTNL: assertion failed at net/ipv6/addrconf.c (1712)
> [   84.346615] CPU: 0 PID: 4842 Comm: trinity-main Not tainted 3.17.0-rc2+ #30
> [   84.347426] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   84.348102]  ffff88003d76a618 ffff880026133d10 ffffffff8238ba79
> ffff8800382d8000
> [   84.349018]  ffff880026133d50 ffffffff820bd5db ffffffff81141555
> ffff8800382d8220
> [   84.349935]  ffff8800382d8000 00000000f76fd1e1 ffff88003d76a618
> ffff8800382d8000
> [   84.350848] Call Trace:
> [   84.351149]  [<ffffffff8238ba79>] dump_stack+0x4d/0x66
> [   84.351751]  [<ffffffff820bd5db>] addrconf_leave_solict+0x4b/0xb0
> [   84.352574]  [<ffffffff81141555>] ? __local_bh_enable_ip+0xa5/0xf0
> [   84.353315]  [<ffffffff820b07b3>] __ipv6_dev_ac_dec+0xc3/0x140
> [   84.354019]  [<ffffffff820b08c8>] ipv6_dev_ac_dec+0x98/0xb0
> [   84.354687]  [<ffffffff820b0bcd>] ipv6_sock_ac_close+0x10d/0x1a0
> [   84.355410]  [<ffffffff820b0aee>] ? ipv6_sock_ac_close+0x2e/0x1a0
> [   84.356147]  [<ffffffff820ae9d3>] inet6_release+0x23/0x40
> [   84.356789]  [<ffffffff81f91834>] sock_release+0x14/0x80
> [   84.357410]  [<ffffffff81f918ad>] sock_close+0xd/0x20
> [   84.358042]  [<ffffffff8127fa91>] __fput+0x111/0x1e0
> [   84.358622]  [<ffffffff8127fba9>] ____fput+0x9/0x10
> [   84.359196]  [<ffffffff8115e3ee>] task_work_run+0x9e/0xd0
> [   84.359825]  [<ffffffff8113f4b6>] do_exit+0x456/0xb30
> [   84.360419]  [<ffffffff823a541c>] ? retint_swapgs+0x13/0x1b
> [   84.361075]  [<ffffffff8113fc54>] do_group_exit+0x84/0xd0
> [   84.361705]  [<ffffffff8113fcaf>] SyS_exit_group+0xf/0x10
> [   84.362338]  [<ffffffff823a47e9>] system_call_fastpath+0x16/0x1b
> [watchdog] [4841] Watchdog exiting because ctrl-c.
> [init] Ran 775 syscalls. Successes: 179  Failures: 596
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Yep,  looks like ipv6_dev_ac_inc() and __ipv6_dev_ac_dec() are called
without RNTL in the socket option path and with RTNL in the address
configuration path.  So it look like this this can actually trigger
list corruptions.

-vlad
