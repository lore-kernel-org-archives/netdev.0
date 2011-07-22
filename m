From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 39742] New: 2.6.39.3 crash and hangs in 1-2
 minutes with igb-RSS and L2TP PPTP services on the NAS server
Date: Fri, 22 Jul 2011 14:42:14 -0700
Message-ID: <20110722144214.577718f0.akpm@linux-foundation.org>
References: <bug-39742-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, cpulinker@yandex.ru,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57704 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932297Ab1GVVmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 17:42:54 -0400
In-Reply-To: <bug-39742-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 22 Jul 2011 10:32:45 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=39742
> 
>            Summary: 2.6.39.3 crash and hangs in 1-2 minutes with igb-RSS
>                     and L2TP PPTP services on the NAS server
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.39.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: cpulinker@yandex.ru
>         Regression: No
> 
> 
> Created an attachment (id=66342)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=66342)
> full trap log, dmesg, iptables, lsmod, ipset
> 
> Hi!
> I set up the server with the new software. It must serves users with VPN
> connections (l2tp,pptp - kernel mode).
> As soon as I start the users it hangs. With latest drivers from Intel (igb) and
> the latest kernel (2.6.39.3)
> it hangs (rarely) or a kernel panic (most often) in 1-2 minutes,
> when users log on to the NAS server and starts to go traffic on VPN
> connections.
> I tried to turn off the incoming shaper on the ifb, disable, conntrack(-j
> NOTRACK in the RAW table),
> was trying to use only PPTP - the kernel still hangs or falls into a panic.
> Hardare is ASUS RS100 - Intel P4 Q6600, x86_64, 4GB RAM, SATA HDD, Intel 82576
> 2 ports (igb with enabled RSS)
> Main software:
> Kernel is 2.6.39 upped to the 2.6.39.3 by patch from
> ftp://ftp.altlinux.org/pub/distributions/ALTLinux/Sisyphus/files/SRPMS/kernel-image-std-def-2.6.39-alt3.src.rpm
> 
> iproute2 2.6.39
> ipset 4.4
> igb 3.1.16
> iptables 1.4.10
> git://accel-ppp.git.sourceforge.net/gitroot/accel-ppp/accel-ppp
> 
> [ 6089.358502] BUG: unable to handle kernel NULL pointer dereference at        
>   (null)
> [ 6089.362482] IP: [<ffffffffa0264e24>] __nf_conntrack_confirm+0x2b4/0x480
> [nf_conntrack]
> [ 6089.362482] PGD 117822067 PUD 117823067 PMD 0
> [ 6089.362482] Oops: 0002 [#1] SMP
> [ 6089.362482] last sysfs file: /sys/devices/virtual/net/ppp6/uevent
> [ 6089.362482] CPU 1
> [ 6089.362482] Modules linked in: act_mirred act_skbedit cls_u32 sch_ingress
> arc4 ecb ppp_mppe l2tp_ppp l2tp_netlink l2tpd
> [ 6089.362482]
> [ 6089.362482] Pid: 0, comm: kworker/0:0 Not tainted 2.6.39-std-def-alt3 #1
> ASUS RS100-E4/PI2/P5M2-M/RS100-E4
> [ 6089.362482] RIP: 0010:[<ffffffffa0264e24>]  [<ffffffffa0264e24>]
> __nf_conntrack_confirm+0x2b4/0x480 [nf_conntrack]
> [ 6089.362482] RSP: 0018:ffff88011fc83a80  EFLAGS: 00010202
> [ 6089.362482] RAX: 00000000000047cd RBX: ffff88011fc94620 RCX:
> 0000000000000000
> [ 6089.362482] RDX: 000000000000fa10 RSI: 00000000d00dd719 RDI:
> ffffffffa026f680
> [ 6089.362482] RBP: ffff88011fc83ac0 R08: 00000000e753847a R09:
> ffff880117f00000
> [ 6089.362482] R10: 0000000000004000 R11: 0000000000000001 R12:
> 0000000000000000
> [ 6089.362482] R13: ffff880116a95080 R14: ffffffff81a4e1c0 R15:
> 00000000000114d8
> [ 6089.362482] FS:  0000000000000000(0000) GS:ffff88011fc80000(0000)
> knlGS:0000000000000000
> [ 6089.362482] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 6089.362482] CR2: 0000000000000000 CR3: 0000000117821000 CR4:
> 00000000000006e0
> [ 6089.362482] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [ 6089.362482] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [ 6089.362482] Process kworker/0:0 (pid: 0, threadinfo ffff880118ef6000, task
> ffff880118ef42c0)
> [ 6089.362482] Stack:
> [ 6089.362482]  000000007d09da80 0000400016bd4400 0000000116ea2000
> ffff880116a95080
> [ 6089.362482]  0000000000000001 ffff88011fc94620 0000000000000002
> ffff880116ea2000
> [ 6089.362482]  ffff88011fc83b30 ffffffffa02b1dd8 ffff880116ea2000
> 0000000000000000
> [ 6089.362482] Call Trace:
> [ 6089.362482]  <IRQ>
> [ 6089.362482]  [<ffffffffa02b1dd8>] ipv4_confirm+0x188/0x1c0
> [nf_conntrack_ipv4]
> [ 6089.362482]  [<ffffffff81382004>] nf_iterate+0x84/0xa0
> [ 6089.362482]  [<ffffffff81389390>] ? ip_rcv_finish+0x390/0x390
> [ 6089.362482]  [<ffffffff81382096>] nf_hook_slow+0x76/0x130
> [ 6089.362482]  [<ffffffff81389390>] ? ip_rcv_finish+0x390/0x390
> [ 6089.362482]  [<ffffffff813897d7>] ip_local_deliver+0x67/0x90
> [ 6089.362482]  [<ffffffff81389135>] ip_rcv_finish+0x135/0x390
> [ 6089.362482]  [<ffffffff81389a1c>] ip_rcv+0x21c/0x2e0
> [ 6089.362482]  [<ffffffff81356f5a>] __netif_receive_skb+0x52a/0x690
> [ 6089.362482]  [<ffffffff813572d0>] netif_receive_skb+0x60/0x90
> [ 6089.362482]  [<ffffffff8124de9c>] ? is_swiotlb_buffer+0x3c/0x50
> [ 6089.362482]  [<ffffffff81357440>] napi_skb_finish+0x50/0x70
> [ 6089.362482]  [<ffffffff813579bd>] napi_gro_receive+0xbd/0xd0
> [ 6089.362482]  [<ffffffffa012129b>] igb_poll+0x6fb/0xae0 [igb]
> [ 6089.362482]  [<ffffffff8107fb61>] ? enqueue_hrtimer+0x31/0x80
> [ 6090.302391]  [<ffffffff81357be5>] net_rx_action+0x135/0x270
> [ 6090.302391]  [<ffffffff81062705>] __do_softirq+0xa5/0x1d0
> [ 6090.302391]  [<ffffffff8141301c>] call_softirq+0x1c/0x30
> [ 6090.302391]  [<ffffffff8100d355>] do_softirq+0x65/0xa0
> [ 6090.302391]  [<ffffffff81062a96>] irq_exit+0x86/0xa0
> [ 6090.302391]  [<ffffffff8100cf01>] do_IRQ+0x61/0xe0
> [ 6090.302391]  [<ffffffff8140a593>] common_interrupt+0x13/0x13
> [ 6090.302391]  <EOI>
> [ 6090.302391]  [<ffffffff81012deb>] ? mwait_idle+0x9b/0x1d0
> [ 6090.302391]  [<ffffffff8140de35>] ? atomic_notifier_call_chain+0x15/0x20
> [ 6090.302391]  [<ffffffff8100a1e6>] cpu_idle+0x56/0xa0
> [ 6090.302391]  [<ffffffff81403729>] start_secondary+0x197/0x19c
> [ 6090.302391] Code: ff 74 09 40 0f b6 ff 41 0f b7 0c 38 66 41 39 cc 0f 84 f1
> fe ff ff 48 8b 00 a8 01 0f 84 51 ff ff ff 4
> 

