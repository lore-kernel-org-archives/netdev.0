From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: 'rmmod -f ipv6': BUG: unable to handle kernel paging request
Date: Thu, 4 Jul 2013 23:04:34 +0200
Message-ID: <20130704210434.GA6381@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

When trying to perform a forceful unload of an ipv6 kernel module
on a 3.10 kernel then I'm getting a kernel panic with the attached
trace.

Is this supposed to happen due to the '-f' option or is this a bug
in the ipv6 code?

Cheers, Linus

-----

[  279.909335] Bridge firewalling registered
[  308.715476] Bridge firewalling registered
[  323.242818] Disabling lock debugging due to kernel taint
[  323.246038] NET: Unregistered protocol family 10
[  323.249021] IPv6: Attempt to unregister permanent protocol 17
[  323.251075] IPv6: Attempt to unregister permanent protocol 136
[  323.292331] IPv6: Attempt to unregister permanent protocol 6
[  323.484732] kmem_cache_destroy ip6_dst_cache: Slab cache still has objects
[  323.487337] CPU: 0 PID: 3066 Comm: rmmod Tainted: G  R          3.10.0 #1
[  323.489555] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  323.491731]  ffff880009c09a58 ffff880005b4fe98 ffffffff813bbc18 ffff880005b4feb8
[  323.492828]  ffffffff811000d0 ffffffffa02aea20 0000000000000000 ffff880005b4fec8
[  323.493914]  ffffffffa0281bb8 ffff880005b4fed8 ffffffffa02a1c85 ffff880005b4ff78
[  323.496748] Call Trace:
[  323.498014]  [<ffffffff813bbc18>] dump_stack+0x19/0x1b
[  323.500621]  [<ffffffff811000d0>] kmem_cache_destroy+0xad/0xc5
[  323.502881]  [<ffffffffa0281bb8>] ip6_route_cleanup+0x60/0x64 [ipv6]
[  323.503650]  [<ffffffffa02a1c85>] inet6_exit+0x59/0xce [ipv6]
[  323.504395]  [<ffffffff810901a0>] SyS_delete_module+0x1df/0x265
[  323.505085]  [<ffffffff813c03c9>] ? retint_swapgs+0xe/0x13
[  323.505749]  [<ffffffff8120dc6e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  323.506517]  [<ffffffff813c64c2>] system_call_fastpath+0x16/0x1b
[  323.544604] BUG: unable to handle kernel paging request at ffff880005940800
[  323.547306] IP: [<ffffffffa02839a3>] fib6_clean_all+0x38/0xfd [ipv6]
[  323.548445] PGD 23ef067 PUD 23f0067 PMD f1bd067 PTE 8000000005940060
[  323.548445] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  323.548445] Modules linked in: stp llc ipv6(-) crc32c libcrc32c crc16 dm_crypt md_mod kvm_amd kvm 8139too snd_pcm snd_page_alloc snd_timer snd soundcore psmouse pcspkr serio_raw evdev processor 8139cp thermal_sys mii button i2c_piix4 i2c_core virtio_pci floppy ata_generic ata_piix libata scsi_mod 9p fscache dm_mirror dm_region_hash dm_log dm_mod 9pnet_virtio virtio_ring virtio 9pnet [last unloaded: bridge]
[  323.548445] CPU: 0 PID: 3066 Comm: rmmod Tainted: G  R          3.10.0 #1
[  323.548445] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  323.548445] task: ffff8800054f2030 ti: ffff880005b4e000 task.ti: ffff880005b4e000
[  323.548445] RIP: 0010:[<ffffffffa02839a3>]  [<ffffffffa02839a3>] fib6_clean_all+0x38/0xfd [ipv6]
[  323.548445] RSP: 0018:ffff880005b4fd98  EFLAGS: 00010286
[  323.548445] RAX: ffff880005940800 RBX: 0000000000000000 RCX: 0000000000000001
[  323.548445] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff8183bbb0
[  323.548445] RBP: ffff880005b4fe38 R08: 0000000000000001 R09: 0000000000000000
[  323.548445] R10: 0000000000000000 R11: ffffffffa02ab840 R12: ffffffff818a8280
[  323.548445] R13: ffffffff818a8280 R14: 0000000000000000 R15: 0000000000000000
[  323.548445] FS:  00007f68ad891700(0000) GS:ffff88000ee00000(0000) knlGS:0000000000000000
[  323.548445] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  323.548445] CR2: ffff880005940800 CR3: 0000000004dfd000 CR4: 00000000000006f0
[  323.548445] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  323.548445] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  323.548445] Stack:
[  323.548445]  ffff880005b4fdb8 ffffffffa02829a4 ffffffffa027fea4 ffffffffa02aee50
[  323.548445]  ffff880005b4fdc8 ffffffff81084d72 ffff880005b4fde8 ffffffff8103cbad
[  323.548445]  0000000000000002 ffffffffa02ab840 ffff880005b4fdf8 ffffffff8103cbd0
[  323.548445] Call Trace:
[  323.548445]  [<ffffffffa02829a4>] ? fib6_add_1.constprop.13+0x306/0x306 [ipv6]
[  323.548445]  [<ffffffffa027fea4>] ? icmp6_dst_gc+0x5d/0x64 [ipv6]
[  323.548445]  [<ffffffff81084d72>] ? trace_hardirqs_on+0xd/0xf
[  323.548445]  [<ffffffff8103cbad>] ? _local_bh_enable_ip+0xb8/0xcd
[  323.548445]  [<ffffffff8103cbd0>] ? local_bh_enable_ip+0xe/0x10
[  323.548445]  [<ffffffff813bfefe>] ? _raw_spin_unlock_bh+0x41/0x46
[  323.548445]  [<ffffffffa0283af0>] fib6_run_gc+0x88/0xd5 [ipv6]
[  323.548445]  [<ffffffffa0286682>] ndisc_netdev_event+0x8f/0xa0 [ipv6]
[  323.548445]  [<ffffffff813106ff>] unregister_netdevice_notifier+0x74/0xbd
[  323.548445]  [<ffffffffa0288084>] ndisc_cleanup+0x15/0x3d [ipv6]
[  323.548445]  [<ffffffffa02a1ca8>] inet6_exit+0x7c/0xce [ipv6]
[  323.548445]  [<ffffffff810901a0>] SyS_delete_module+0x1df/0x265
[  323.548445]  [<ffffffff813c03c9>] ? retint_swapgs+0xe/0x13
[  323.548445]  [<ffffffff8120dc6e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  323.548445]  [<ffffffff813c64c2>] system_call_fastpath+0x16/0x1b
[  323.548445] Code: cf 41 56 41 89 d6 41 55 41 54 49 89 fc 53 31 db 48 83 ec 78 48 89 b5 68 ff ff ff e8 c6 e9 ff ff 49 8b 84 24 28 07 00 00 48 01 d8 <4c> 8b 28 e8 5d 0e dd e0 85 c0 0f 84 87 00 00 00 80 3d 7b a6 02
[  323.548445] RIP  [<ffffffffa02839a3>] fib6_clean_all+0x38/0xfd [ipv6]
[  323.548445]  RSP <ffff880005b4fd98>
[  323.548445] CR2: ffff880005940800
[  323.548445] ---[ end trace 32c5095c4ee29375 ]---
[  323.548445] Kernel panic - not syncing: Fatal exception in interrupt
