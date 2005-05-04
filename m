From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: TCP4/6 socket closure causing system crash..
Date: Wed, 4 May 2005 15:57:52 +0300
Message-ID: <20050504125752.GA7399@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have CVS-pserver running under a chroot wrapper.
Recently system has become unresponsive the instance somebody
refers to the pserver...

I have three kernels to choose from:

  title Fedora Core (2.6.11-1.1282_FC4smp)
  title Fedora Core (2.6.11-1.1276_FC4smp)
  title Fedora Core (2.6.11-1.1191_FC4smp)

First two crash, third works just fine for this workset.

Serial console capture tells following:

   -----------------

Kernel 2.6.11-1.1282_FC4smp on an i686

mismatch in kmem_cache_free: expected cache f78ee500, got f7972800
f7972800 is TCP.
f78ee500 is TCPv6.
Badness in cache_free_debugcheck at mm/slab.c:1926 (Not tainted)
 [<c014c64a>] cache_free_debugcheck+0xb3/0x222
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c014d20d>] kmem_cache_free+0x2a/0x69
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c02a58c1>] __kfree_skb+0x54/0x146
 [<f8854c85>] scsi_finish_command+0x7d/0xd1 [scsi_mod]
 [<c02ab285>] net_tx_action+0x4e/0x121
 [<f8854bbd>] scsi_softirq+0x9a/0xbf [scsi_mod]
 [<c0126582>] __do_softirq+0x72/0xdc
 [<c010667b>] do_softirq+0x4b/0x4f
 =======================
 [<c0106569>] do_IRQ+0x55/0x86
 [<c02e0f4f>] tcp_v4_destroy_sock+0x9/0x16f
 [<c0104a6a>] common_interrupt+0x1a/0x20
 [<c014007b>] cpuset_zonelist_valid_mems_allowed+0x3/0x3f
 [<c0308f10>] _spin_lock+0x12/0x40
 [<c01634f8>] __fput+0xbe/0x10e
 [<c01d73eb>] _atomic_dec_and_lock+0x27/0x44
 [<c0177bff>] dput+0xe5/0x1df
 [<c01634ff>] __fput+0xc5/0x10e
 [<c0161f51>] filp_close+0x4f/0x6d
 [<c012331a>] put_files_struct+0x6e/0xe7
 [<c0124037>] do_exit+0xfc/0x36a
 [<c012b284>] __dequeue_signal+0xe9/0x1aa
 [<c01242fa>] do_group_exit+0x29/0x90
 [<c012cd07>] get_signal_to_deliver+0x263/0x371
 [<c0103e47>] do_signal+0x5d/0x111
 [<c014b028>] poison_obj+0x20/0x3d
 [<c014c6cf>] cache_free_debugcheck+0x138/0x222
 [<c0161ece>] sys_open+0x4a/0x5b
 [<c01193a1>] do_page_fault+0x0/0x6a7
 [<c0103f23>] do_notify_resume+0x28/0x39
 [<c01040c6>] work_notifysig+0x13/0x15
slab error in cache_free_debugcheck(): cache `TCP': double free, or memory outside object was overwritten
 [<c014c735>] cache_free_debugcheck+0x19e/0x222
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c014d20d>] kmem_cache_free+0x2a/0x69
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c02a58c1>] __kfree_skb+0x54/0x146
 [<f8854c85>] scsi_finish_command+0x7d/0xd1 [scsi_mod]
 [<c02ab285>] net_tx_action+0x4e/0x121
 [<f8854bbd>] scsi_softirq+0x9a/0xbf [scsi_mod]
 [<c0126582>] __do_softirq+0x72/0xdc
 [<c010667b>] do_softirq+0x4b/0x4f
 =======================
 [<c0106569>] do_IRQ+0x55/0x86
 [<c02e0f4f>] tcp_v4_destroy_sock+0x9/0x16f
 [<c0104a6a>] common_interrupt+0x1a/0x20
 [<c014007b>] cpuset_zonelist_valid_mems_allowed+0x3/0x3f
 [<c0308f10>] _spin_lock+0x12/0x40
 [<c01634f8>] __fput+0xbe/0x10e
 [<c01d73eb>] _atomic_dec_and_lock+0x27/0x44
 [<c0177bff>] dput+0xe5/0x1df
 [<c01634ff>] __fput+0xc5/0x10e
 [<c0161f51>] filp_close+0x4f/0x6d
 [<c012331a>] put_files_struct+0x6e/0xe7
 [<c0124037>] do_exit+0xfc/0x36a
 [<c012b284>] __dequeue_signal+0xe9/0x1aa
 [<c01242fa>] do_group_exit+0x29/0x90
 [<c012cd07>] get_signal_to_deliver+0x263/0x371
 [<c0103e47>] do_signal+0x5d/0x111
 [<c014b028>] poison_obj+0x20/0x3d
 [<c014c6cf>] cache_free_debugcheck+0x138/0x222
 [<c0161ece>] sys_open+0x4a/0x5b
 [<c01193a1>] do_page_fault+0x0/0x6a7
 [<c0103f23>] do_notify_resume+0x28/0x39
 [<c01040c6>] work_notifysig+0x13/0x15
f6456f10: redzone 1: 0x170fc2a5, redzone 2: 0x0.
------------[ cut here ]------------
kernel BUG at mm/slab.c:1946!
invalid operand: 0000 [#1]
SMP 
Modules linked in: parport_pc lp parport w83627hf eeprom i2c_sensor i2c_isa ip_conntrack_ftp ipt_conntrack iptable_mangle ipt_state ip_conntrack ipt_REJECT iptable_filter ip_tables ip6table_filter ip6_tables md5 ipv6 dm_mod video button battery ac ohci1394 ieee1394 uhci_hcd ehci_hcd hw_random tpm_nsc tpm i2c_i801 i2c_core snd_intel8x0 snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc e100 mii sk98lin dummy floppy ext3 jbd raid1 qla2300 qla2xxx scsi_transport_fc sata_sil ata_piix libata aic7xxx scsi_transport_spi sd_mod scsi_mod
CPU:    0
EIP:    0060:[<c014c7ac>]    Not tainted VLI
EFLAGS: 00010016   (2.6.11-1.1282_FC4smp) 
EIP is at cache_free_debugcheck+0x215/0x222
eax: f6456dcc   ebx: 00012c00   ecx: 00000ca8   edx: 00000144
esi: f7972800   edi: f6456124   ebp: f6456f10   esp: c040bf48
ds: 007b   es: 007b   ss: 0068
Process cvs (pid: 7668, threadinfo=c040b000 task=d7882020)
Stack: c03206d4 f6456f10 170fc2a5 00000000 c0451840 c02a42a7 f6456f14 f7972800 
       f7d79f18 00000286 c014d20d f6456f14 00000000 c2012480 0000000a c02a42a7 
       f7ce0fc0 f7ce0ff8 c23b002c f31b8b3c f51dde3c c02a58c1 f7d5b8f4 0000000a 
Call Trace:
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c014d20d>] kmem_cache_free+0x2a/0x69
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c02a58c1>] __kfree_skb+0x54/0x146
 [<f8854c85>] scsi_finish_command+0x7d/0xd1 [scsi_mod]
 [<c02ab285>] net_tx_action+0x4e/0x121
 [<f8854bbd>] scsi_softirq+0x9a/0xbf [scsi_mod]
 [<c0126582>] __do_softirq+0x72/0xdc
 [<c010667b>] do_softirq+0x4b/0x4f
 =======================
 [<c0106569>] do_IRQ+0x55/0x86
 [<c02e0f4f>] tcp_v4_destroy_sock+0x9/0x16f
 [<c0104a6a>] common_interrupt+0x1a/0x20
 [<c014007b>] cpuset_zonelist_valid_mems_allowed+0x3/0x3f
 [<c0308f10>] _spin_lock+0x12/0x40
 [<c01634f8>] __fput+0xbe/0x10e
 [<c01d73eb>] _atomic_dec_and_lock+0x27/0x44
 [<c0177bff>] dput+0xe5/0x1df
 [<c01634ff>] __fput+0xc5/0x10e
 [<c0161f51>] filp_close+0x4f/0x6d
 [<c012331a>] put_files_struct+0x6e/0xe7
 [<c0124037>] do_exit+0xfc/0x36a
 [<c012b284>] __dequeue_signal+0xe9/0x1aa
 [<c01242fa>] do_group_exit+0x29/0x90
 [<c012cd07>] get_signal_to_deliver+0x263/0x371
 [<c0103e47>] do_signal+0x5d/0x111
 [<c014b028>] poison_obj+0x20/0x3d
 [<c014c6cf>] cache_free_debugcheck+0x138/0x222
 [<c0161ece>] sys_open+0x4a/0x5b
 [<c01193a1>] do_page_fault+0x0/0x6a7
 [<c0103f23>] do_notify_resume+0x28/0x39
 [<c01040c6>] work_notifysig+0x13/0x15
Code: 8b 9e b4 00 00 00 e9 d0 fe ff ff 89 ea 89 f0 e8 fb e3 ff ff 81 38 a5 c2 0f 17 75 87 eb c4 0f 0b 99 07 53 fb 31 c0 e9 d9 fe ff ff <0f> 0b 9a 07 53 fb 31 c0 e9 da fe ff ff 55 57 56 53 83 ec 14 89 
 <0>Kernel panic - not syncing: Fatal exception in interrupt
 [<c0121118>] panic+0x45/0x1e8
 [<c010539d>] die+0x17b/0x185
 [<c01055db>] do_invalid_op+0x0/0xab
 [<c010567d>] do_invalid_op+0xa2/0xab
 [<c014c7ac>] cache_free_debugcheck+0x215/0x222
 [<c01218e4>] call_console_drivers+0x80/0x14c
 [<c0121e67>] release_console_sem+0x78/0xb5
 [<c0121cbb>] vprintk+0x1f5/0x2a9
 [<c0104bc3>] error_code+0x4f/0x54
 [<c014c7ac>] cache_free_debugcheck+0x215/0x222
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c014d20d>] kmem_cache_free+0x2a/0x69
 [<c02a42a7>] sk_free+0x7e/0xff
 [<c02a58c1>] __kfree_skb+0x54/0x146
 [<f8854c85>] scsi_finish_command+0x7d/0xd1 [scsi_mod]
 [<c02ab285>] net_tx_action+0x4e/0x121
 [<f8854bbd>] scsi_softirq+0x9a/0xbf [scsi_mod]
 [<c0126582>] __do_softirq+0x72/0xdc
 [<c010667b>] do_softirq+0x4b/0x4f
 =======================
 [<c0106569>] do_IRQ+0x55/0x86
 [<c02e0f4f>] tcp_v4_destroy_sock+0x9/0x16f
 [<c0104a6a>] common_interrupt+0x1a/0x20
 [<c014007b>] cpuset_zonelist_valid_mems_allowed+0x3/0x3f
 [<c0308f10>] _spin_lock+0x12/0x40
 [<c01634f8>] __fput+0xbe/0x10e
 [<c01d73eb>] _atomic_dec_and_lock+0x27/0x44
 [<c0177bff>] dput+0xe5/0x1df
 [<c01634ff>] __fput+0xc5/0x10e
 [<c0161f51>] filp_close+0x4f/0x6d
 [<c012331a>] put_files_struct+0x6e/0xe7
 [<c0124037>] do_exit+0xfc/0x36a
 [<c012b284>] __dequeue_signal+0xe9/0x1aa
 [<c01242fa>] do_group_exit+0x29/0x90
 [<c012cd07>] get_signal_to_deliver+0x263/0x371
 [<c0103e47>] do_signal+0x5d/0x111
 [<c014b028>] poison_obj+0x20/0x3d
 [<c014c6cf>] cache_free_debugcheck+0x138/0x222
 [<c0161ece>] sys_open+0x4a/0x5b
 [<c01193a1>] do_page_fault+0x0/0x6a7
 [<c0103f23>] do_notify_resume+0x28/0x39
 [<c01040c6>] work_notifysig+0x13/0x15
