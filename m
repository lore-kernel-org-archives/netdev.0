From: Richard GENOUD <richard.genoud@gmail.com>
Subject: hv_netvsc: WARNING in softirq.c
Date: Thu, 28 Feb 2013 09:34:38 +0100
Message-ID: <20130228083437.GA28143@lnx-rg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hi,

Here is the kernel trace I got this morning (kern.log):
Feb 27 22:32:59 devlabo kernel: [10688.187062] hv_vmbus: child device vmbus_0_8 unregistered
Feb 27 22:34:37 devlabo kernel: [10688.187196] ------------[ cut here ]------------
Feb 27 22:34:37 devlabo kernel: [10688.187203] WARNING: at /build/buildd-linux_3.2.35-2-amd64-v9djlH/linux-3.2.35/kernel/softirq.c:159 _local_bh_enable_ip.isra.11+0x3d/0x88()
Feb 27 22:34:37 devlabo kernel: [10688.187206] Hardware name: Virtual Machine
Feb 27 22:34:37 devlabo kernel: [10688.187208] Modules linked in: des_generic ecb md4 hmac nls_utf8 cifs nfsd nfs nfs_acl auth_rpcgss fscache lockd sunrpc loop snd_pcm snd_page_alloc snd_timer snd joydev processor hid_hyperv crc32c_intel hid thermal_sys i2c_piix4 evdev button soundcore hv_utils i2c_core psmouse serio_raw pcspkr ext4 crc16 jbd2 mbcache sd_mod crc_t10dif hv_netvsc hv_storvsc sg sr_mod cdrom ata_generic floppy hv_vmbus ata_piix libata scsi_mod [last unloaded: scsi_wait_scan]
Feb 27 22:34:37 devlabo kernel: [10688.187244] Pid: 0, comm: swapper/0 Not tainted 3.2.0-4-amd64 #1 Debian 3.2.35-2
Feb 27 22:34:37 devlabo kernel: [10688.187246] Call Trace:
Feb 27 22:34:37 devlabo kernel: [10688.187248]  <IRQ>  [<ffffffff81046a75>] ? warn_slowpath_common+0x78/0x8c
Feb 27 22:34:37 devlabo kernel: [10688.187257]  [<ffffffff8104bf76>] ? _local_bh_enable_ip.isra.11+0x3d/0x88
Feb 27 22:34:37 devlabo kernel: [10688.187262]  [<ffffffffa00a59b5>] ? rndis_filter_receive+0x236/0x259 [hv_netvsc]
Feb 27 22:34:37 devlabo kernel: [10688.187267]  [<ffffffffa00a4e5f>] ? netvsc_channel_cb+0x37a/0x449 [hv_netvsc]
Feb 27 22:34:37 devlabo kernel: [10688.187273]  [<ffffffffa006211b>] ? vmbus_on_event+0x91/0xdd [hv_vmbus]
Feb 27 22:34:37 devlabo kernel: [10688.187277]  [<ffffffff812432d5>] ? add_interrupt_randomness+0x38/0x155
Feb 27 22:34:37 devlabo kernel: [10688.187283]  [<ffffffff8104b89a>] ? tasklet_action+0x73/0xc2
Feb 27 22:34:37 devlabo kernel: [10688.187287]  [<ffffffff8104c084>] ? __do_softirq+0xb9/0x177
Feb 27 22:34:37 devlabo kernel: [10688.187292]  [<ffffffff8135426c>] ? call_softirq+0x1c/0x30
Feb 27 22:34:37 devlabo kernel: [10688.187297]  [<ffffffff8100f8dd>] ? do_softirq+0x3c/0x7b
Feb 27 22:34:37 devlabo kernel: [10688.187300]  [<ffffffff8104c2ec>] ? irq_exit+0x3c/0x9a
Feb 27 22:34:37 devlabo kernel: [10688.187303]  [<ffffffff8100f60d>] ? do_IRQ+0x82/0x98
Feb 27 22:34:37 devlabo kernel: [10688.187307]  [<ffffffff8134d32e>] ? common_interrupt+0x6e/0x6e
Feb 27 22:34:37 devlabo kernel: [10688.187309]  <EOI>  [<ffffffff81065dbd>] ? timekeeping_get_ns+0xd/0x2a
Feb 27 22:34:37 devlabo kernel: [10688.187317]  [<ffffffff8106bc20>] ? arch_local_irq_enable+0x4/0x8
Feb 27 22:34:37 devlabo kernel: [10688.187321]  [<ffffffff8100d286>] ? cpu_idle+0xe8/0xf2
Feb 27 22:34:37 devlabo kernel: [10688.187324]  [<ffffffff816abb33>] ? start_kernel+0x3b3/0x3be
Feb 27 22:34:37 devlabo kernel: [10688.187328]  [<ffffffff816ab140>] ? early_idt_handlers+0x140/0x140
Feb 27 22:34:37 devlabo kernel: [10688.187331]  [<ffffffff816ab3c4>] ? x86_64_start_kernel+0x104/0x111
Feb 27 22:34:37 devlabo kernel: [10688.187333] ---[ end trace 39158641c6e4b495 ]---

and there was a lot of them :
Feb 26 22:35:14 devlabo kernel: [37398.788119] ------------[ cut here ]------------
Feb 26 22:35:14 devlabo kernel: [37398.788129] WARNING: at /build/buildd-linux_3.2.35-2-amd64-v9djlH/linux-3.2.35/kernel/softirq.c:159 _local_bh_enable_ip.isra.11+0x3d/0x88()
Feb 26 22:35:14 devlabo kernel: [37398.788132] Hardware name: Virtual Machine
Feb 26 22:35:14 devlabo kernel: [37398.788133] Modules linked in: nfsd nfs nfs_acl auth_rpcgss lockd sunrpc des_generic ecb md4 hmac nls_utf8 cifs fscache loop snd_pcm snd_page_alloc snd_timer joydev crc32c_intel i2c_piix4 snd processor hid_hyperv hid hv_utils soundcore button thermal_sys pcspkr i2c_core psmouse evdev serio_raw ext4 crc16 jbd2 mbcache sd_mod crc_t10dif hv_netvsc hv_storvsc sg sr_mod cdrom ata_generic ata_piix libata scsi_mod floppy hv_vmbus [last unloaded: scsi_wait_scan]
Feb 26 22:35:14 devlabo kernel: [37398.788169] Pid: 0, comm: swapper/0 Not tainted 3.2.0-4-amd64 #1 Debian 3.2.35-2
Feb 26 22:35:14 devlabo kernel: [37398.788171] Call Trace:
Feb 26 22:35:14 devlabo kernel: [37398.788172]  <IRQ>  [<ffffffff81046a75>] ? warn_slowpath_common+0x78/0x8c
Feb 26 22:35:14 devlabo kernel: [37398.788181]  [<ffffffff8104bf76>] ? _local_bh_enable_ip.isra.11+0x3d/0x88
Feb 26 22:35:14 devlabo kernel: [37398.788186]  [<ffffffffa009e9b5>] ? rndis_filter_receive+0x236/0x259 [hv_netvsc]
Feb 26 22:35:14 devlabo kernel: [37398.788190]  [<ffffffffa009de5f>] ? netvsc_channel_cb+0x37a/0x449 [hv_netvsc]
Feb 26 22:35:14 devlabo kernel: [37398.788196]  [<ffffffffa000111b>] ? vmbus_on_event+0x91/0xdd [hv_vmbus]
Feb 26 22:35:14 devlabo kernel: [37398.788200]  [<ffffffff8104b89a>] ? tasklet_action+0x73/0xc2
Feb 26 22:35:14 devlabo kernel: [37398.788203]  [<ffffffff8104c084>] ? __do_softirq+0xb9/0x177
Feb 26 22:35:14 devlabo kernel: [37398.788207]  [<ffffffff81061755>] ? run_posix_cpu_timers+0x23/0x346
Feb 26 22:35:14 devlabo kernel: [37398.788211]  [<ffffffff8135426c>] ? call_softirq+0x1c/0x30
Feb 26 22:35:14 devlabo kernel: [37398.788216]  [<ffffffff8100f8dd>] ? do_softirq+0x3c/0x7b
Feb 26 22:35:14 devlabo kernel: [37398.788218]  [<ffffffff8104c2ec>] ? irq_exit+0x3c/0x9a
Feb 26 22:35:14 devlabo kernel: [37398.788222]  [<ffffffff810241c8>] ? smp_apic_timer_interrupt+0x74/0x82
Feb 26 22:35:14 devlabo kernel: [37398.788225]  [<ffffffff81352ade>] ? apic_timer_interrupt+0x6e/0x80
Feb 26 22:35:14 devlabo kernel: [37398.788227]  <EOI>  [<ffffffff81013a17>] ? native_sched_clock+0x27/0x2f
Feb 26 22:35:14 devlabo kernel: [37398.788233]  [<ffffffff8102b360>] ? native_safe_halt+0x2/0x3
Feb 26 22:35:14 devlabo kernel: [37398.788236]  [<ffffffff81014508>] ? default_idle+0x47/0x7f
Feb 26 22:35:14 devlabo kernel: [37398.788238]  [<ffffffff8100d24d>] ? cpu_idle+0xaf/0xf2
Feb 26 22:35:14 devlabo kernel: [37398.788241]  [<ffffffff816abb33>] ? start_kernel+0x3b3/0x3be
Feb 26 22:35:14 devlabo kernel: [37398.788244]  [<ffffffff816ab140>] ? early_idt_handlers+0x140/0x140
Feb 26 22:35:14 devlabo kernel: [37398.788247]  [<ffffffff816ab3c4>] ? x86_64_start_kernel+0x104/0x111
Feb 26 22:35:14 devlabo kernel: [37398.788249] ---[ end trace 8f3991272dc0c5cc ]---
Feb 26 22:35:14 devlabo kernel: [37398.789256] hv_vmbus: child device vmbus_0_8 unregistered

Feb  3 22:31:55 devlabo kernel: [37819.617243] ------------[ cut here ]------------
Feb  3 22:31:55 devlabo kernel: [37819.617253] WARNING: at /build/buildd-linux_3.2.35-2-amd64-v9djlH/linux-3.2.35/kernel/softirq.c:159 _local_bh_enable_ip.isra.11+0x3d/0x88()
Feb  3 22:31:55 devlabo kernel: [37819.617257] Hardware name: Virtual Machine
Feb  3 22:31:55 devlabo kernel: [37819.617259] Modules linked in: nfsd nfs nfs_acl auth_rpcgss lockd sunrpc des_generic ecb md4 hmac nls_utf8 cifs fscache loop joydev snd_pcm hid_hyperv hid snd_page_alloc snd_timer snd hv_utils i2c_piix4 i2c_core soundcore processor psmouse crc32c_intel thermal_sys button pcspkr evdev serio_raw ext4 crc16 jbd2 mbcache sd_mod crc_t10dif hv_netvsc hv_storvsc sg sr_mod cdrom ata_generic hv_vmbus ata_piix floppy libata scsi_mod [last unloaded: scsi_wait_scan]
Feb  3 22:31:55 devlabo kernel: [37819.617308] Pid: 0, comm: swapper/0 Not tainted 3.2.0-4-amd64 #1 Debian 3.2.35-2
Feb  3 22:31:55 devlabo kernel: [37819.617311] Call Trace:
Feb  3 22:31:55 devlabo kernel: [37819.617313]  <IRQ>  [<ffffffff81046a75>] ? warn_slowpath_common+0x78/0x8c
Feb  3 22:31:55 devlabo kernel: [37819.617324]  [<ffffffff8104bf76>] ? _local_bh_enable_ip.isra.11+0x3d/0x88
Feb  3 22:31:55 devlabo kernel: [37819.617331]  [<ffffffffa00a09b5>] ? rndis_filter_receive+0x236/0x259 [hv_netvsc]
Feb  3 22:31:55 devlabo kernel: [37819.617339]  [<ffffffffa009fe5f>] ? netvsc_channel_cb+0x37a/0x449 [hv_netvsc]
Feb  3 22:31:55 devlabo kernel: [37819.617347]  [<ffffffffa006211b>] ? vmbus_on_event+0x91/0xdd [hv_vmbus]
Feb  3 22:31:55 devlabo kernel: [37819.617353]  [<ffffffff8104b89a>] ? tasklet_action+0x73/0xc2
Feb  3 22:31:55 devlabo kernel: [37819.617357]  [<ffffffff8104c084>] ? __do_softirq+0xb9/0x177
Feb  3 22:31:55 devlabo kernel: [37819.617362]  [<ffffffff81061755>] ? run_posix_cpu_timers+0x23/0x346
Feb  3 22:31:55 devlabo kernel: [37819.617366]  [<ffffffff8104c350>] ? raise_softirq_irqoff+0x6/0x25
Feb  3 22:31:55 devlabo kernel: [37819.617372]  [<ffffffff8135426c>] ? call_softirq+0x1c/0x30
Feb  3 22:31:55 devlabo kernel: [37819.617378]  [<ffffffff8100f8dd>] ? do_softirq+0x3c/0x7b
Feb  3 22:31:55 devlabo kernel: [37819.617382]  [<ffffffff8104c2ec>] ? irq_exit+0x3c/0x9a
Feb  3 22:31:55 devlabo kernel: [37819.617387]  [<ffffffff810241c8>] ? smp_apic_timer_interrupt+0x74/0x82
Feb  3 22:31:55 devlabo kernel: [37819.617391]  [<ffffffff81352ade>] ? apic_timer_interrupt+0x6e/0x80
Feb  3 22:31:55 devlabo kernel: [37819.617394]  <EOI>  [<ffffffff81013a17>] ? native_sched_clock+0x27/0x2f
Feb  3 22:31:55 devlabo kernel: [37819.617402]  [<ffffffff8102b360>] ? native_safe_halt+0x2/0x3
Feb  3 22:31:55 devlabo kernel: [37819.617407]  [<ffffffff81014508>] ? default_idle+0x47/0x7f
Feb  3 22:31:55 devlabo kernel: [37819.617411]  [<ffffffff8100d24d>] ? cpu_idle+0xaf/0xf2
Feb  3 22:31:55 devlabo kernel: [37819.617415]  [<ffffffff816abb33>] ? start_kernel+0x3b3/0x3be
Feb  3 22:31:55 devlabo kernel: [37819.617420]  [<ffffffff816ab140>] ? early_idt_handlers+0x140/0x140
Feb  3 22:31:55 devlabo kernel: [37819.617424]  [<ffffffff816ab3c4>] ? x86_64_start_kernel+0x104/0x111
Feb  3 22:31:55 devlabo kernel: [37819.617427] ---[ end trace a20acc0adc92e993 ]---
Feb  3 22:31:55 devlabo kernel: [37819.618127] hv_vmbus: child device vmbus_0_8 unregistered

It does not happen every day, but quite often : 4 times in February
I'll ask my sysadm if there's something special at 22h30 in the host,
because it's always happening around this time.

Machine is debian wheezy (7) under windows server 2008 R2

Regards
Richard
