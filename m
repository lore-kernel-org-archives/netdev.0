From: Frank Arnold <frank.arnold@amd.com>
Subject: bridge br_multicast: BUG: unable to handle kernel NULL pointer
 dereference
Date: Mon, 5 Jul 2010 21:05:37 +0200
Message-ID: <1278356737.2163.45.camel@mendozza.osrc.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:17877
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751422Ab0GETUu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 15:20:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we see a kernel NULL pointer dereference during testing of the KVM tree=
,
currently based on 2.6.35-rc3. We are using bridge to connect the KVM
guests through the hosts network interface. Here is the trace:

BUG: unable to handle kernel NULL pointer dereference at
0000000000000028                                              =20
IP: [<ffffffffa0196da0>] __br_ip4_hash+0x0/0x7c [bridge]               =
                                                =20
PGD 0                                                                  =
                                                =20
Oops: 0000 [#1] SMP                                                    =
                                                =20
last sysfs file: /sys/module/lockd/initstate                           =
                                                =20
CPU 3                                                                  =
                                                =20
Modules linked in: nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc b=
ridge stp ipv6 kvm_amd kvm snd_hda_codec_atihdmi=20
snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm sn=
d_timer snd pcspkr serio_raw ata_generic r8169 so
undcore i2c_piix4 pata_acpi i2c_core joydev snd_page_alloc mii pata_ati=
ixp shpchp [last unloaded: scsi_wait_scan]      =20
                                                                       =
                                                =20
Pid: 0, comm: swapper Not tainted 2.6.35.20100705_8dea564-1.fc11.osrc.x=
86_64 #1 GA-MA74GM-S2H/GA-MA74GM-S2H            =20
RIP: 0010:[<ffffffffa0196da0>]  [<ffffffffa0196da0>] __br_ip4_hash+0x0/=
0x7c [bridge]                                   =20
RSP: 0018:ffff880001b838a8  EFLAGS: 00010246                           =
                                                =20
RAX: ffff880126028000 RBX: 0000000000000000 RCX: ffff880127b3a828      =
                                                =20
RDX: 0000000001b80008 RSI: 0000000064ffffef RDI: 0000000000000000      =
                                                =20
RBP: ffff880001b838b0 R08: ffff8800054c3870 R09: 0000000000000000      =
                                                =20
R10: 0000000000000000 R11: 0000000000000000 R12: ffff880001b83a00      =
                                                =20
R13: ffff880001b83a00 R14: ffff880127b3a800 R15: ffff880125ccc400      =
                                                =20
=46S:  00007f17d45ea6f0(0000) GS:ffff880001b80000(0000) knlGS:000000000=
0000000                                           =20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b                      =
                                                =20
CR2: 0000000000000028 CR3: 00000000016b0000 CR4: 00000000000006e0      =
                                                =20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000      =
                                                =20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400      =
                                                =20
Process swapper (pid: 0, threadinfo ffff880127ab4000, task ffff880127ab=
96b0)                                           =20
Stack:                                                                 =
                                                =20
 ffffffffa0196f48 ffff880001b838d0 ffffffffa01970be ffff880126028640   =
                                                =20
<0> ffff880125ccc400 ffff880001b83910 ffffffffa0197511 ffff880001b83900=
                                                =20
<0> ffff880127b3a800 ffff8800054c3868 ffff880126028640 ffff880127b3a800=
                                                =20
Call Trace:                                                            =
                                                =20
 <IRQ>                                                                 =
                                                =20
 [<ffffffffa0196f48>] ? br_ip_hash+0x1f/0x28 [bridge]                  =
                                                =20
 [<ffffffffa01970be>] br_mdb_ip_get+0x12/0x24 [bridge]                 =
                                                =20
 [<ffffffffa0197511>] br_multicast_leave_group+0x62/0x160 [bridge]     =
                                                =20
 [<ffffffffa0199028>] br_multicast_rcv+0x60e/0xcda [bridge]            =
                                                =20
 [<ffffffff81043320>] ? local_bh_enable_ip+0x9/0xb                     =
                                                =20
 [<ffffffff81369f85>] ? _raw_spin_unlock_bh+0xf/0x11                   =
                                                =20
 [<ffffffff812f9a1a>] ? packet+0x1a/0x24                               =
                                                =20
 [<ffffffff812f777b>] ? nf_conntrack_in+0x4ee/0x59f                    =
                                                =20
 [<ffffffffa01907d5>] ? fdb_create+0x28/0x73 [bridge]                  =
                                                =20
 [<ffffffffa0190945>] ? br_fdb_update+0x125/0x134 [bridge]             =
                                                =20
 [<ffffffffa0191e74>] br_handle_frame_finish+0x6d/0x1ba [bridge]       =
                                                =20
 [<ffffffffa0191e07>] ? br_handle_frame_finish+0x0/0x1ba [bridge]      =
                                                =20
 [<ffffffffa0195c79>] NF_HOOK_THRESH+0x46/0x4d [bridge]                =
                                                =20
 [<ffffffffa0195ed2>] ? nf_bridge_push_encap_header+0x2f/0x3c [bridge] =
                                                =20
 [<ffffffffa0196c65>] br_nf_pre_routing_finish+0x222/0x231 [bridge]    =
                                                =20
 [<ffffffff812f4a10>] ? nf_hook_slow+0x65/0xc6                         =
                                                =20
 [<ffffffffa0196a43>] ? br_nf_pre_routing_finish+0x0/0x231 [bridge]    =
                                                =20
 [<ffffffffa0196a43>] ? br_nf_pre_routing_finish+0x0/0x231 [bridge]    =
                                                =20
 [<ffffffffa0195c79>] NF_HOOK_THRESH+0x46/0x4d [bridge]                =
                                                =20
 [<ffffffffa019609a>] ? nf_bridge_alloc+0x1d/0x3a [bridge]             =
                                                =20
 [<ffffffffa0196a26>] br_nf_pre_routing+0x550/0x56d [bridge]           =
                                                =20
 [<ffffffff812f4968>] nf_iterate+0x41/0x84                             =
                                                =20
 [<ffffffffa0191e07>] ? br_handle_frame_finish+0x0/0x1ba [bridge]      =
                                                =20
 [<ffffffff812f4a10>] nf_hook_slow+0x65/0xc6                           =
                                                =20
 [<ffffffffa0191e07>] ? br_handle_frame_finish+0x0/0x1ba [bridge]      =
                                                =20
 [<ffffffffa0191e07>] ? br_handle_frame_finish+0x0/0x1ba [bridge]      =
                                                =20
 [<ffffffffa0191df5>] NF_HOOK.clone.0+0x41/0x53 [bridge]               =
                                                =20
 [<ffffffffa0192137>] br_handle_frame+0x176/0x18f [bridge]             =
                                                =20
 [<ffffffff812d54e5>] __netif_receive_skb+0x2b0/0x3f5                  =
                                                =20
 [<ffffffff810592d2>] ? ktime_get_real+0x11/0x3e                       =
                                                =20
 [<ffffffff812d612c>] netif_receive_skb+0x52/0x59                      =
                                                =20
 [<ffffffff812d0ce6>] ? __netdev_alloc_skb+0x2f/0x4b                   =
                                                =20
 [<ffffffffa0054ff1>] rtl8169_rx_interrupt+0x385/0x4d6 [r8169]         =
                                                =20
 [<ffffffff81222203>] ? scsi_next_command+0x3e/0x46                    =
                                                =20
 [<ffffffff812354b3>] ? __ata_qc_complete+0xdf/0xe7                    =
                                                =20
 [<ffffffffa0057614>] rtl8169_poll+0x37/0x1a1 [r8169]                  =
                                                =20
 [<ffffffff812d62ed>] net_rx_action+0xab/0x18c                         =
                                                =20
 [<ffffffffa00565f4>] ? rtl8169_interrupt+0x2cb/0x36e [r8169]          =
                                                =20
 [<ffffffff81043446>] __do_softirq+0x97/0x125                          =
                                                =20
 [<ffffffff8101a026>] ? ack_apic_level+0x78/0x1ce                      =
                                                =20
 [<ffffffff810038dc>] call_softirq+0x1c/0x28                           =
                                                =20
 [<ffffffff81004e61>] do_softirq+0x41/0x7e                             =
                                                =20
 [<ffffffff810431ce>] irq_exit+0x36/0x78                               =
                                                =20
 [<ffffffff8100459c>] do_IRQ+0xa7/0xbe                                 =
                                                =20
 [<ffffffff8136a1d3>] ret_from_intr+0x0/0x11                           =
                                                =20
 <EOI>                                                                 =
                                                =20
 [<ffffffff8102036c>] ? native_safe_halt+0x6/0x8                       =
                                                =20
 [<ffffffff8136d161>] ? atomic_notifier_call_chain+0x13/0x15           =
                                                =20
 [<ffffffff81009696>] default_idle+0x27/0x44                           =
                                                =20
 [<ffffffff81001d3a>] cpu_idle+0x58/0x93                               =
                                                =20
 [<ffffffff81364944>] start_secondary+0x1a4/0x1a8                      =
                                                =20
Code: 7e 66 81 fa 81 00 74 0d 31 c0 66 81 fa 88 64 0f 94 c0 c1 e0 03 89=
 c2 48 29 93 e0 00 00 00 01 43 68 31 c0 5b 41 5c=20
c9 c3 90 90 90 <8b> 47 28 89 f1 ba b9 79 37 9e c1 e9 0d 29 f2 55 29 f0 =
48 89 e5                                        =20
RIP  [<ffffffffa0196da0>] __br_ip4_hash+0x0/0x7c [bridge]              =
                                                =20
 RSP <ffff880001b838a8>                                                =
                                                =20
CR2: 0000000000000028                                                  =
                                                =20
---[ end trace c0f05a4e3727475d ]---                                   =
                                                =20
Kernel panic - not syncing: Fatal exception in interrupt               =
                                                =20


--=20
=46rank Arnold=20
Systems Design Technician, Software Test
AMD Operating System Research Center
Dresden, Germany
Tel: +49 351 448 356702


Legal Information:
Advanced Micro Devices GmbH
Einsteinring 24
85609 Dornach b. M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Alberto Bozzo, Andrew Bowd
Sitz: Dornach, Gemeinde Aschheim, Landkreis M=C3=BCnchen
Registergericht M=C3=BCnchen, HRB Nr. 43632


