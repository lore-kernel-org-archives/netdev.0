From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in udpv6_sendmsg
Date: Fri, 29 Mar 2013 11:49:18 -0700
Message-ID: <1364582958.5113.49.camel@edumazet-glaptop>
References: <20130329184006.GA23893@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:62779 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756453Ab3C2StV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 14:49:21 -0400
Received: by mail-pb0-f41.google.com with SMTP id mc8so367770pbc.0
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 11:49:21 -0700 (PDT)
In-Reply-To: <20130329184006.GA23893@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 14:40 -0400, Dave Jones wrote:
> Just hit this on Linus' current tree.
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000031
> IP: [<ffffffff8166ca6b>] udpv6_sendmsg+0x34b/0xa90
> PGD 67f4e067 PUD 60281067 PMD 0 
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in: dlci 8021q garp mrp fuse vmw_vsock_vmci_transport vmw_vmci vsock bnep hidp bridge stp rfcomm l2tp_ppp l2tp_netlink l2tp_core phonet af_key af_rxrpc caif_socket caif rose llc2 netrom can_raw cmtp kernelcapi nfnetlink ipt_ULOG can_bcm can af_802154 scsi_transport_iscsi pppoe ipx atm ax25 p8023 p8022 nfc pppox decnet irda ppp_generic x25 slhc rds crc_ccitt appletalk psnap llc lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables snd_hda_codec_realtek raid0 snd_hda_intel snd_hda_codec snd_pcm btusb microcode snd_page_alloc serio_raw snd_timer bluetooth pcspkr snd edac_core rfkill soundcore r8169 mii vhost_net tun macvtap macvlan kvm_amd kvm radeon backlight drm_kms_helper ttm
> CPU 0 
> Pid: 22781, comm: trinity-child33 Not tainted 3.9.0-rc4+ #7 Gigabyte Technology Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
> RIP: 0010:[<ffffffff8166ca6b>]  [<ffffffff8166ca6b>] udpv6_sendmsg+0x34b/0xa90
> RSP: 0018:ffff880011811a70  EFLAGS: 00010206
> RAX: 0000000000000005 RBX: ffff8800167a7000 RCX: ffff8800167a7618
> RDX: ffff8800167a7248 RSI: ffff88011959d680 RDI: ffff88011959d680
> RBP: ffff880011811ba0 R08: ffff8800167a75f8 R09: 0000000000000001
> R10: ffff8800603f2490 R11: 0000000000000002 R12: 00000000ffffffe0
> R13: ffff8800167a75f8 R14: ffff88011959d680 R15: ffff8800167a75f8
> FS:  00007f655b275740(0000) GS:ffff88012a600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000031 CR3: 000000008e94a000 CR4: 00000000000007f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process trinity-child33 (pid: 22781, threadinfo ffff880011810000, task ffff8800603f2490)
> Stack:
>  ffff880000000000 0000000000000000 ffff880011811b28 ffff88011959d680
>  00000000200065c0 ffffffff00000000 ffff8800167a7600 ffff8800167a75f8
>  0000000011811ac0 0000000000000000 ffff8800167a7618 ffff8800167a7248
> Call Trace:
>  [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
>  [<ffffffff810b3348>] ? trace_hardirqs_off_caller+0x28/0xc0
>  [<ffffffff816076ac>] inet_sendmsg+0x10c/0x220
>  [<ffffffff816075a5>] ? inet_sendmsg+0x5/0x220
>  [<ffffffff81567b37>] sock_sendmsg+0xb7/0xe0
>  [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
>  [<ffffffff810b3462>] ? get_lock_stats+0x22/0x70
>  [<ffffffff810b3b8e>] ? put_lock_stats.isra.27+0xe/0x40
>  [<ffffffff810b418c>] ? lock_release_holdtime.part.28+0x9c/0x150
>  [<ffffffff81578286>] ? verify_iovec+0x56/0xd0
>  [<ffffffff8156884e>] __sys_sendmsg+0x3ae/0x3c0
>  [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
>  [<ffffffff810b3462>] ? get_lock_stats+0x22/0x70
>  [<ffffffff810b3b8e>] ? put_lock_stats.isra.27+0xe/0x40
>  [<ffffffff810b41d5>] ? lock_release_holdtime.part.28+0xe5/0x150
>  [<ffffffff8100a144>] ? native_sched_clock+0x24/0x80
>  [<ffffffff810b3348>] ? trace_hardirqs_off_caller+0x28/0xc0
>  [<ffffffff810b3b8e>] ? put_lock_stats.isra.27+0xe/0x40
>  [<ffffffff816c512c>] ? _raw_spin_unlock_irq+0x2c/0x60
>  [<ffffffff811dbe5c>] ? fget_light+0x38c/0x500
>  [<ffffffff8156a989>] sys_sendmsg+0x49/0x90
>  [<ffffffff816cd942>] system_call_fastpath+0x16/0x1b
> Code: dc 03 f0 ff 48 8b 4c 24 50 4c 8b 44 24 38 48 8b 54 24 58 49 89 4d 48 4d 89 45 50 49 8b 86 a0 00 00 00 48 85 c0 0f 84 6c 06 00 00 <8b> 40 2c 41 89 45 74 48 89 d7 e8 66 85 05 00 45 85 e4 7e 1e 41 
> RIP  [<ffffffff8166ca6b>] udpv6_sendmsg+0x34b/0xa90
>  RSP <ffff880011811a70>
> CR2: 0000000000000031
> ---[ end trace aafad9c3e4a4dfb2 ]---
> 
> All code
> ========
>    0:	dc 03                	faddl  (%rbx)
>    2:	f0 ff 48 8b          	lock decl -0x75(%rax)
>    6:	4c 24 50             	rex.WR and $0x50,%al
>    9:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
>    e:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
>   13:	49 89 4d 48          	mov    %rcx,0x48(%r13)
>   17:	4d 89 45 50          	mov    %r8,0x50(%r13)
>   1b:	49 8b 86 a0 00 00 00 	mov    0xa0(%r14),%rax
>   22:	48 85 c0             	test   %rax,%rax
>   25:	0f 84 6c 06 00 00    	je     0x697
>   2b:*	8b 40 2c             	mov    0x2c(%rax),%eax     <-- trapping instruction
>   2e:	41 89 45 74          	mov    %eax,0x74(%r13)
>   32:	48 89 d7             	mov    %rdx,%rdi
>   35:	e8 66 85 05 00       	callq  0x585a0
>   3a:	45 85 e4             	test   %r12d,%r12d
>   3d:	7e 1e                	jle    0x5d
>   3f:	41                   	rex.B
> 
> which looks like this in udpv6_sendmsg ..
> 
> 
>         np->daddr_cache = daddr;
>      ca3:       49 89 4d 48             mov    %rcx,0x48(%r13)
> #ifdef CONFIG_IPV6_SUBTREES
>         np->saddr_cache = saddr;
>      ca7:       4d 89 45 50             mov    %r8,0x50(%r13)
> #endif
>         np->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
>      cab:       49 8b 86 a0 00 00 00    mov    0xa0(%r14),%rax
>      cb2:       48 85 c0                test   %rax,%rax
>      cb5:       0f 84 6c 06 00 00       je     1327 <udpv6_sendmsg+0x9b7>
>      cbb:       8b 40 2c                mov    0x2c(%rax),%eax
>      cbe:       41 89 45 74             mov    %eax,0x74(%r13)
>         raw_spin_lock_irqsave_nested(spinlock_check(lock), flags, subclass); \
> } while (0)
> 
> Looks like the last line of an inlined __ip6_dst_store() call. So line 1243 of net/ipv6/udp.c
> 
> 	Dave

Yes, I had the same problem on my lab machine yesterday and was working
on it (Using a linux-3.3.8 code base)

In my case, the invalid rt6i_node value was 0x66b579de

<1>[ 1307.437873] BUG: unable to handle kernel paging request at 0000000066b57a02
<1>[ 1307.444845] IP: [<ffffffffa001997b>] udpv6_sendmsg+0x28b/0xb20 [ipv6]
<4>[ 1307.451290] PGD 6f218f067 PUD 0
<4>[ 1307.454550] Oops: 0000 [#1] SMP
<0>[ 1307.458062] gsmi: Log Shutdown Reason 0x04
<4>[ 1307.462147] CPU 3
<4>[ 1307.463987] Modules linked in: nvram tun 8021q bridge stp llc ipt_ULOG ip_queue nfnetlink act_mirred cls_tcindex sch_dsmark ipt_USE_CACHED_DSCP ipt_UPDATE_CACHED_DSCP xt_DSCP xt_dscp xt_multiport iptable_mangle pca954x i2c_mux cdc_acm uhci_hcd ehci_hcd i2c_dev i2c_i801 i2c_core i2c_debug msr cpuid genrtc mlx4_en ib_uverbs mlx4_ib ib_mad ib_core mlx4_core e1000e bnx2x libcrc32c mdio ipv6
<4>[ 1307.499017]
<4>[ 1307.500515] Pid: 4135, comm: trinity-child23 Tainted: G        W    3.3.8-smp-DEV #293 
<4>[ 1307.510969] RIP: 0010:[<ffffffffa001997b>]  [<ffffffffa001997b>] udpv6_sendmsg+0x28b/0xb20 [ipv6]
<4>[ 1307.519839] RSP: 0018:ffff8806cd393a68  EFLAGS: 00010206
<4>[ 1307.525141] RAX: 0000000000000000 RBX: ffff88011a350580 RCX: 00000000ffffffa6
<4>[ 1307.532257] RDX: 0000000066b579de RSI: ffff880132298c80 RDI: ffff880132298c80
<4>[ 1307.539367] RBP: ffff8806cd393ba8 R08: 00000000ffff8008 R09: 0000000000000040
<4>[ 1307.546484] R10: ffff88011a350990 R11: 0000000000000001 R12: ffff88011a350990
<4>[ 1307.553604] R13: ffff88011a350970 R14: ffff88011a350970 R15: ffff880132298c80
<4>[ 1307.560721] FS:  0000000000b04880(0063) GS:ffff88067fc60000(0000) knlGS:0000000000000000
<4>[ 1307.568790] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[ 1307.574523] CR2: 0000000066b57a02 CR3: 00000006ebe90000 CR4: 00000000000006e0
<4>[ 1307.581640] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[ 1307.588757] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[ 1307.595867] Process trinity-child23 (pid: 4135, threadinfo ffff8806cd392000, task ffff8806f4b8d340)
<4>[ 1307.604889] Stack:
<4>[ 1307.606903]  0000000000000000 0000000000000000 ffff8806cd393b38 ffff880132298c80
<4>[ 1307.614386]  0000000000005a8a ffff880100000000 ffff8806cd393b28 ffffffff8045f149
<4>[ 1307.621859]  ffff8801ffffffa6 0000000000000000 0000000000000000 ffff8806cd393b38
<4>[ 1307.629333] Call Trace:
<4>[ 1307.631781]  [<ffffffff8045f149>] ? ext4_da_write_end+0x99/0x370
<4>[ 1307.637771]  [<ffffffff80348e3c>] ? generic_file_buffered_write+0x1ac/0x280
<4>[ 1307.644717]  [<ffffffff80776a64>] inet_sendmsg+0x64/0xb0
<4>[ 1307.650017]  [<ffffffff806e9327>] sock_sendmsg+0x117/0x130
<4>[ 1307.655494]  [<ffffffff8034a459>] ? __generic_file_aio_write+0x229/0x440
<4>[ 1307.662178]  [<ffffffff806ebfed>] ? move_addr_to_kernel+0x4d/0x90
<4>[ 1307.668260]  [<ffffffff806f8faa>] ? verify_iovec+0x4a/0xd0
<4>[ 1307.673734]  [<ffffffff806ea6ec>] __sys_sendmsg+0x38c/0x3a0
<4>[ 1307.679299]  [<ffffffff802ab439>] ? enqueue_hrtimer+0x39/0xc0
<4>[ 1307.685034]  [<ffffffff802ac318>] ? hrtimer_start+0x18/0x20
<4>[ 1307.690592]  [<ffffffff802876e4>] ? do_setitimer+0x234/0x2a0
<4>[ 1307.696242]  [<ffffffff806ed155>] sys_sendmsg+0x75/0xf0
<4>[ 1307.701458]  [<ffffffff807c8172>] system_call_fastpath+0x16/0x1b
