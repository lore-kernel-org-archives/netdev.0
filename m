From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: Re: [AX25] kernel panic
Date: Mon, 21 Sep 2009 10:44:14 +0200
Message-ID: <4AB73CDE.4030709@upmc.fr>
References: <4AA82BF0.7040203@upmc.fr> <20090910142436.GB10547@linux-mips.org> <4AA9288B.2070205@upmc.fr> <20090911120557.GA12175@linux-mips.org> <4AB5EAE5.6070605@upmc.fr> <20090920210242.GA9804@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090920210242.GA9804@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarek,

Good fishing !

During the night I catched the following two identical AX25_DBG messages with netconsole
sending already reported message: kernel BUG at kernel/timer.c:913!  and followed by kernel
panics and the machine rebooting.


Sep 21 03:24:06 f6bvp-11 klogd: ------------[ cut here ]------------
Sep 21 03:24:06 f6bvp-11 klogd: WARNING: at include/net/ax25.h:260 ax25_kiss_rcv+0x650/0xab0 [ax25]()
Sep 21 03:24:06 f6bvp-11 klogd: Hardware name: MS-7258
Sep 21 03:24:06 f6bvp-11 klogd: Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl aut
h_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss
 snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss i2c_viapro snd i2c
_core soundcore 8139cp 8139too shpchp pci_hotplug mii sr_mod binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservative 
cpufreq_powersave acpi_cpufreq freq_table floppy rtc_cmos processor thermal button via_agp sg evdev pata_via ata_generic
 ide_pci_generic pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Sep 21 03:24:06 f6bvp-11 klogd: Pid: 5, comm: events/0 Not tainted 2.6.31-nosmp #3
Sep 21 03:24:06 f6bvp-11 klogd: Call Trace:
Sep 21 03:24:06 f6bvp-11 klogd:  <IRQ>  [<ffffffffa03ab750>] ? ax25_kiss_rcv+0x650/0xab0 [ax25]
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff81053b90>] warn_slowpath_common+0x80/0xe0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff81053c12>] warn_slowpath_null+0x22/0x40
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffffa03ab750>] ax25_kiss_rcv+0x650/0xab0 [ax25]
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8132b4bd>] ? sock_def_readable+0x3d/0x80
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8132c96d>] ? sock_queue_rcv_skb+0x12d/0x160
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8133a831>] netif_receive_skb+0x351/0x5f0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff81061699>] ? run_timer_softirq+0x179/0x250
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8133ab50>] process_backlog+0x80/0xe0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8133b4a4>] net_rx_action+0xf4/0x220
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8105b242>] __do_softirq+0xe2/0x1d0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8101414a>] call_softirq+0x1a/0x30
Sep 21 03:24:06 f6bvp-11 klogd:  <EOI>  [<ffffffff810162c5>] do_softirq+0x75/0xc0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8105b094>] local_bh_enable+0xc4/0xd0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffffa03cd798>] mkiss_receive_buf+0x3a8/0x460 [mkiss]
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8104b864>] ? finish_task_switch+0x44/0xe0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff812af800>] flush_to_ldisc+0x110/0x1f0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff812af6f0>] ? flush_to_ldisc+0x0/0x1f0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8106c263>] worker_thread+0x173/0x260
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff81071be0>] ? autoremove_wake_function+0x0/0x60
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8106c0f0>] ? worker_thread+0x0/0x260
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8107149e>] kthread+0xae/0xc0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff8101404a>] child_rip+0xa/0x20
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff810713f0>] ? kthread+0x0/0xc0
Sep 21 03:24:06 f6bvp-11 klogd:  [<ffffffff81014040>] ? child_rip+0x0/0x20
Sep 21 03:24:06 f6bvp-11 klogd: ---[ end trace cea93cec47668ffd ]---
Sep 21 03:24:06 f6bvp-11 klogd: AX25_DBG: 1 ffff88005a127c00 0

Sep 21 04:30:40 f6bvp-11 klogd: ------------[ cut here ]------------
Sep 21 04:30:40 f6bvp-11 klogd: WARNING: at include/net/ax25.h:260 ax25_kiss_rcv+0x650/0xab0 [ax25]()
Sep 21 04:30:40 f6bvp-11 klogd: Hardware name: MS-7258
Sep 21 04:30:40 f6bvp-11 klogd: Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_rawmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer snd_page_alloc snd_mixer_oss snd 8139cp i2c_viapro 8139too soundcore i2c_core shpchp sr_mod mii pci_hotplug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_table processor rtc_cmos floppy button thermal via_agp evdev sg pata_via ata_generic ide_pci_generic pata_acpi sata_via libata sd_mod scsi_mod crc_t10dif
Sep 21 04:30:40 f6bvp-11 klogd: Pid: 5, comm: events/0 Not tainted 2.6.31-nosmp #3
Sep 21 04:30:40 f6bvp-11 klogd: Call Trace:
Sep 21 04:30:40 f6bvp-11 klogd:  <IRQ>  [<ffffffffa03ab750>] ? ax25_kiss_rcv+0x650/0xab0 [ax25]
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff81053b90>] warn_slowpath_common+0x80/0xe0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff81053c12>] warn_slowpath_null+0x22/0x40
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffffa03ab750>] ax25_kiss_rcv+0x650/0xab0 [ax25]
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8132b4bd>] ? sock_def_readable+0x3d/0x80
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8132c96d>] ? sock_queue_rcv_skb+0x12d/0x160
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8133a831>] netif_receive_skb+0x351/0x5f0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff81061699>] ? run_timer_softirq+0x179/0x250
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8133ab50>] process_backlog+0x80/0xe0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8133b4a4>] net_rx_action+0xf4/0x220
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8105b242>] __do_softirq+0xe2/0x1d0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8101414a>] call_softirq+0x1a/0x30
Sep 21 04:30:40 f6bvp-11 klogd:  <EOI>  [<ffffffff810162c5>] do_softirq+0x75/0xc0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8105b094>] local_bh_enable+0xc4/0xd0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffffa03cd798>] mkiss_receive_buf+0x3a8/0x460 [mkiss]
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8104b864>] ? finish_task_switch+0x44/0xe0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff812af800>] flush_to_ldisc+0x110/0x1f0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8106c71c>] ? schedule_delayed_work+0x2c/0x50
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff812af6f0>] ? flush_to_ldisc+0x0/0x1f0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8106c263>] worker_thread+0x173/0x260
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff81071be0>] ? autoremove_wake_function+0x0/0x60
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8106c0f0>] ? worker_thread+0x0/0x260
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8107149e>] kthread+0xae/0xc0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff8101404a>] child_rip+0xa/0x20
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff810713f0>] ? kthread+0x0/0xc0
Sep 21 04:30:40 f6bvp-11 klogd:  [<ffffffff81014040>] ? child_rip+0x0/0x20
Sep 21 04:30:40 f6bvp-11 klogd: ---[ end trace 5e079e87d8b30365 ]---
Sep 21 04:30:40 f6bvp-11 klogd: AX25_DBG: 1 ffff880064471c00 0


Regards,


Bernard
