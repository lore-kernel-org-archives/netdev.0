From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 09:46:41 -0500
Message-ID: <52B45851.90208@mojatatu.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>	 <52B434FA.8080309@mojatatu.com> <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:48386 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab3LTOqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:46:50 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so15206846igc.3
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:46:49 -0800 (PST)
In-Reply-To: <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 09:37, Eric Dumazet wrote:
> On Fri, 2013-12-20 at 07:15 -0500, Jamal Hadi Salim wrote:

>> Please Cc me - my filters will catch it faster.
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This doesn't fix the issue, as I said earlier
>

That is strange - I have net-next from when these patches made it
in and no problem booting with statically linked mirred.
I will try to pull the latest later and rebuild.
The patch above will fix the issue on the dumping of actions. I am only
these additional patches I havent paid much attention to.

cheers,
jamal


> Even not using a module but static linking for act_mirred triggers the
> following :
>
> [   86.909685] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)^M
> [   86.917183] BUG: unable to handle kernel paging request at ffffffff818a4b80^M
> [   86.924190] IP: [<ffffffff818a4b80>] 0xffffffff818a4b80^M
> [   86.929439] PGD 180c067 PUD 180d063 PMD 202e851063 PTE 80000000018a4163^M
> [   86.936144] Oops: 0011 [#1] SMP ^M
> [   86.939405] Modules linked in: cls_tcindex sch_dsmark xt_multiport iptable_mangle w1_therm wire cdc_acm uhci_hcd ehci_hcd i2c_dev i2c_i801 i2c_core msr cpuid ib_uverbs mlx4_ib ib_sa ib_mad mlx4_en ib_core mlx4_core ipv6^M
> [   86.959307] CPU: 11 PID: 11378 Comm: BweTCTree_DoWor Not tainted 3.13.0-smp-DEV #413^M
> [   86.973964] task: ffff880078fc6690 ti: ffff882016886000 task.ti: ffff882016886000^M
> [   86.981467] RIP: 0010:[<ffffffff818a4b80>]  [<ffffffff818a4b80>] 0xffffffff818a4b80^M
> [   86.989153] RSP: 0018:ffff8820168879b0  EFLAGS: 00010206^M
> [   86.994482] RAX: 0000000000010000 RBX: ffff881015c59480 RCX: 0000000000000000^M
> [   87.001635] RDX: ffffffff818a4b50 RSI: ffffffffa0059790 RDI: ffff881015c59480^M
> [   87.008772] RBP: ffff882016887aa8 R08: ffff88107f4004c0 R09: ffff881015c59480^M
> [   87.015922] R10: ffff880000077680 R11: 00000000ffffff97 R12: ffff881016ae9160^M
> [   87.023094] R13: ffff881016ae9000 R14: ffff881016ae9000 R15: ffff88102e405800^M
> [   87.030277] FS:  00007f29f3858700(0000) GS:ffff88107fb60000(0000) knlGS:0000000000000000^M
> [   87.038386] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
> [   87.044146] CR2: ffffffff818a4b80 CR3: 0000002030af1000 CR4: 00000000001407e0^M
> [   87.051301] Stack:^M
> [   87.053314]  ffffffff814dd0e1 0000000000000028 00000000ffffffff ffffffff818a4b50^M
> [   87.060774]  ffff880000077680 ffff88102e405824 0000000800000000 ffffffff818a1940^M
> [   87.068232]  0000000000000000 ffffffff8169ca80 0001000000010000 ffff882016887a68^M
> [   87.075750] Call Trace:^M
> [   87.078202]  [<ffffffff814dd0e1>] ? tc_ctl_tfilter+0x4a1/0x760^M
> [   87.084071]  [<ffffffff814e6fb6>] ? __netlink_sendskb+0x56/0x130^M
> [   87.090108]  [<ffffffff814caa04>] rtnetlink_rcv_msg+0xa4/0x240^M
> [   87.095945]  [<ffffffff814ca960>] ? __rtnl_unlock+0x20/0x20^M
> [   87.101538]  [<ffffffff814e9e91>] netlink_rcv_skb+0xb1/0xc0^M
> [   87.107118]  [<ffffffff814c7635>] rtnetlink_rcv+0x25/0x40^M
> [   87.112528]  [<ffffffff814e973d>] netlink_unicast+0x14d/0x1f0^M
> [   87.118314]  [<ffffffff814e9ae3>] netlink_sendmsg+0x303/0x410^M
> [   87.124092]  [<ffffffff814a048c>] sock_sendmsg+0x9c/0xd0^M
> [   87.129451]  [<ffffffff814a0da0>] ? move_addr_to_kernel+0x40/0xa0^M
> [   87.135566]  [<ffffffff814add21>] ? verify_iovec+0x51/0xd0^M
> [   87.141064]  [<ffffffff814a0c21>] ___sys_sendmsg+0x3c1/0x3d0^M
> [   87.146747]  [<ffffffff815690bc>] ? __do_page_fault+0x26c/0x500^M
> [   87.152689]  [<ffffffff811821ab>] ? do_brk+0x1bb/0x320^M
> [   87.157830]  [<ffffffff814a1809>] __sys_sendmsg+0x49/0x90^M
> [   87.163250]  [<ffffffff814a1862>] SyS_sendmsg+0x12/0x20^M
> [   87.168484]  [<ffffffff8156d992>] system_call_fastpath+0x16/0x1b^M
> [   87.174518] Code: ff ff ff 80 97 05 a0 ff ff ff ff 00 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00 80 4b 8a 81 ff ff ff ff 80 4b 8a 81 ff ff ff ff <70> 4b 8a 81 ff ff ff ff 70 4b 8a 81 ff ff ff ff c0 9d ba 81 ff ^M
> [   87.194642] RIP  [<ffffffff818a4b80>] 0xffffffff818a4b80^M
> [   87.199983]  RSP <ffff8820168879b0>^M
> [   87.203472] CR2: ffffffff818a4b80^M
> [   87.206785] ---[ end trace 8ef37a4cc4cb5a8c ]---^M
> [   87.211408] Kernel panic - not syncing: Fatal exception^M
> [   87.216763] Rebooting in 10 seconds..^M
>
> We actually try to execute code at ffffffff818a4b80 == &act_mirred_ops
>
> ffffffff818a4b40 d cls_mod_lock
> ffffffff818a4b50 d tcf_proto_base
> ffffffff818a4b60 d act_mod_lock
> ffffffff818a4b70 d act_base
> ffffffff818a4b80 d act_mirred_ops
> ffffffff818a4bf0 d mirred_device_notifier
> ffffffff818a4c10 d mirred_list
> ffffffff818a4c20 d _rs.42828
> ffffffff818a4c40 d ematch_mod_lock
> ffffffff818a4c50 d ematch_ops
>
>
