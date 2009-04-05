From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Sun, 05 Apr 2009 15:49:14 +0200
Message-ID: <49D8B6DA.7050902@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BED109.3020504@cosmosbay.com> <49D66379.7070106@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39779 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbZDENuE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 09:50:04 -0400
In-Reply-To: <49D66379.7070106@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz a =E9crit :
> Hi Eric,
>=20
> We've been experimenting with this softirq-delay patch in production,=
 and
> have seen some hard-to-reproduce crashes. We finally managed to captu=
re a
> kexec crashdump this morning.
>=20
> This is the dmesg:
>=20
> [53417.592868] Unable to handle kernel NULL pointer dereference at
> 0000000000000000 RIP:
> [53417.598377]  [<ffffffff80243643>] __do_softirq+0xc3/0x150
> [53417.606300] PGD 32abb8067 PUD 32faf5067 PMD 0
> [53417.610829] Oops: 0000 [1] SMP
> [53417.614032] CPU 2
> [53417.616083] Modules linked in: nfs lockd nfs_acl sunrpc openafs(P)
> autofs4 ipv6 ac sbs sbshc video output dock battery container
> iptable_filter ip_tables x_tables parport_pc lp parport loop joydev
> iTCO_wdt iTCO_vendor_support evdev button i5000_edac psmouse serio_ra=
w
> pcspkr shpchp pci_hotplug edac_core ext3 jbd mbcache sr_mod cdrom
> ata_generic usbhid hid ata_piix sg sd_mod ehci_hcd pata_acpi uhci_hcd
> libata bnx2 aacraid usbcore scsi_mod thermal processor fan fbcon
> tileblit font bitblit softcursor fuse
> [53417.662067] Pid: 13039, comm: gball Tainted: P      =20
> 2.6.24-19acr2-generic #1
> [53417.669219] RIP: 0010:[<ffffffff80243643>]  [<ffffffff80243643>]
> __do_softirq+0xc3/0x150
> [53417.677368] RSP: 0018:ffff8103314f3f20  EFLAGS: 00010297
> [53417.682697] RAX: ffff810084a1b000 RBX: ffffffff805ba530 RCX:
> 0000000000000000
> [53417.689843] RDX: ffff8103305811e0 RSI: 0000000000000282 RDI:
> ffff810332ada580
> [53417.696993] RBP: 0000000000000000 R08: ffff81032fad9f08 R09:
> ffff810332382000
> [53417.704144] R10: 0000000000000000 R11: ffffffff80316ec0 R12:
> ffffffff8062b3d8
> [53417.711294] R13: ffffffff8062b480 R14: 0000000000000002 R15:
> 000000000000000a
> [53417.718447] FS:  00007fab0d7b8750(0000) GS:ffff810334401b80(0000)
> knlGS:0000000000000000
> [53417.726568] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [53417.732332] CR2: 0000000000000000 CR3: 0000000329e2d000 CR4:
> 00000000000006e0
> [53417.739476] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [53417.746637] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [53417.753787] Process gball (pid: 13039, threadinfo ffff81032adde000=
,
> task ffff810329ff77d0)
> [53417.761991] Stack:  ffffffff8062b3d8 0000000000000046
> ffff8103314f3f68 0000000000000000
> [53417.770146]  00000000000000a0 ffff81032addfee8 0000000000000000
> ffffffff8020d50c
> [53417.777660]  ffff8103314f3f68 00000000000000c1 ffffffff8020ed25
> ffffffff8062c870
> [53417.784961] Call Trace:
> [53417.787635]  <IRQ>  [<ffffffff8020d50c>] call_softirq+0x1c/0x30
> [53417.793597]  [<ffffffff8020ed25>] do_softirq+0x35/0x90
> [53417.798747]  [<ffffffff80243578>] irq_exit+0x88/0x90
> [53417.803727]  [<ffffffff8020ef70>] do_IRQ+0x80/0x100
> [53417.808624]  [<ffffffff8020c891>] ret_from_intr+0x0/0xa
> [53417.813862]  <EOI>  [<ffffffff803e53c8>] skb_release_all+0x18/0x15=
0
> [53417.820164]  [<ffffffff803e4ad9>] __kfree_skb+0x9/0x90
> [53417.825327]  [<ffffffff80437612>] udp_recvmsg+0x222/0x260
> [53417.830744]  [<ffffffff80231264>] source_load+0x34/0x70
> [53417.835984]  [<ffffffff80232a9a>] find_busiest_group+0x1fa/0x850
> [53417.842019]  [<ffffffff803e0100>] sock_common_recvmsg+0x30/0x50
> [53417.847958]  [<ffffffff803de1ca>] sock_recvmsg+0x14a/0x160
> [53417.853462]  [<ffffffff80231c21>] update_curr+0x71/0x100
> [53419.858789]  [<ffffffff802320fd>] __dequeue_entity+0x3d/0x50
> [53417.864469]  [<ffffffff80253ab0>] autoremove_wake_function+0x0/0x3=
0
> [53417.870758]  [<ffffffff8046662f>] thread_return+0x3a/0x57b
> [53417.876262]  [<ffffffff803df73e>] sys_recvfrom+0xfe/0x190
> [53417.881680]  [<ffffffff802e2a95>] sys_epoll_wait+0x245/0x4e0
> [53417.887358]  [<ffffffff80233e20>] default_wake_function+0x0/0x10
> [53417.893384]  [<ffffffff8020c37e>] system_call+0x7e/0x83
> [53417.898628]
> [53417.900134]
> [53417.900134] Code: 48 8b 11 48 89 cf 65 48 8b 04 25 08 00 00 00 4a =
89
> 14 20 ff
> [53417.909430] RIP  [<ffffffff80243643>] __do_softirq+0xc3/0x150
> [53417.915210]  RSP <ffff8103314f3f20>
>=20
> The disassembly where it crashed:
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:273
> ffffffff8024361b:       d1 ed                   shr    %ebp
> rcu_bh_qsctr_inc():
> /local/home/bmb/doc/kernels/linux-hardy-eric/include/linux/rcupdate.h=
:130
> ffffffff8024361d:       48 8b 40 08             mov    0x8(%rax),%rax
> ffffffff80243621:       41 c7 44 05 08 01 00    movl =20
> $0x1,0x8(%r13,%rax,1)
> ffffffff80243628:       00 00
> __do_softirq():
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:273
> ffffffff8024362a:       75 d8                   jne    ffffffff802436=
04
> <__do_softirq+0x84>
> softirq_delay_exec():
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:225
> ffffffff8024362c:       48 8b 14 24             mov    (%rsp),%rdx
> ffffffff80243630:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
> ffffffff80243637:       00 00
> ffffffff80243639:       48 8b 0c 10             mov    (%rax,%rdx,1),=
%rcx
> ffffffff8024363d:       48 83 f9 01             cmp    $0x1,%rcx
> ffffffff80243641:       74 29                   je     ffffffff802436=
6c
> <__do_softirq+0xec>
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:226
> ffffffff80243643:       48 8b 11                mov    (%rcx),%rdx
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:227
> ffffffff80243646:       48 89 cf                mov    %rcx,%rdi
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:226
> ffffffff80243649:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
> ffffffff80243650:       00 00
> ffffffff80243652:       4a 89 14 20             mov    %rdx,(%rax,%r1=
2,1)
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:227
> ffffffff80243656:       ff 51 08                callq  *0x8(%rcx)
> /local/home/bmb/doc/kernels/linux-hardy-eric/kernel/softirq.c:225
> ffffffff80243659:       65 48 8b 04 25 08 00    mov    %gs:0x8,%rax
> ffffffff80243660:       00 00
> ffffffff80243662:       4a 8b 0c 20             mov    (%rax,%r12,1),=
%rcx
> ffffffff80243666:       48 83 f9 01             cmp    $0x1,%rcx
> ffffffff8024366a:       75 d7                   jne    ffffffff802436=
43
> <__do_softirq+0xc3>
> raw_local_irq_disable():
> /local/home/bmb/doc/kernels/linux-hardy-eric/debian/build/build-gener=
ic/include2/asm/irqflags_64.h:76
>=20
> ffffffff8024366c:       fa                      cli
>=20
> And softirq.c line numbers:
>    218   * Because locking is provided by subsystem, please note
>    219   * that sdel->func(sdel) is responsible for setting sdel->nex=
t
> to NULL
>    220   */
>    221  static void softirq_delay_exec(void)
>    222  {
>    223          struct softirq_delay *sdel;
>    224
>    225          while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=
=3D
> SOFTIRQ_DELAY_END) {
>    226                  __get_cpu_var(softirq_delay_head) =3D sdel->n=
ext;
>    227                  sdel->func(sdel);       /*      sdel->next =3D
> NULL;*/
>    228                  }
>    229  }
>=20
> So it's crashing because __get_cpu_var(softirq_delay_head)) is NULL
> somehow.
>=20
> We aren't running a recent kernel -- we're running Ubuntu Hardy's
> 2.6.24-19,
> with a backported version of this patch. One more atypical thing is t=
hat
> we run openafs, 1.4.6.dfsg1-2.
>=20
> Like I said, I have a full vmcore (3, actually) and would be happy to
> post any
> more information you'd like to know.
>=20
> Thanks,
> Brian Bloniarz

Hi Brian

2.6.24-19 kernel... hmm...

Could you please send me the diff of your backport against this kernel =
?

I take you use Ubuntu Hardys 8.04 LTS server edition ?

Pointer being null might tell us that we managed to call inet_def_reada=
ble()
without socket lock hold...

