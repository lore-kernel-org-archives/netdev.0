From: Massimo Cetra <ctrixk@navynet.it>
Subject: Re: [Bug #14378] Problems with net/core/skbuff.c
Date: Tue, 13 Oct 2009 11:11:17 +0200
Message-ID: <4AD44435.3050703@navynet.it>
References: <zJ_pXHNwoHC.A.akB.Aal0KB@chimera>	<r-4Wjt4coy.A.CwC.Wal0KB@chimera> <20091012.034224.64980795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070700000508040107060507"
Cc: rjw@sisk.pl, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host179-6-static.238-77-b.business.telecomitalia.it ([77.238.6.179]:55104
	"EHLO mail.navynet.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353AbZJMJYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 05:24:25 -0400
In-Reply-To: <20091012.034224.64980795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070700000508040107060507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller ha scritto:
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> Date: Mon, 12 Oct 2009 00:22:04 +0200 (CEST)
>
>   
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14378
>> Subject		: Problems with net/core/skbuff.c
>> Submitter	: Massimo Cetra <mcetra@navynet.it>
>> Date		: 2009-10-08 14:51 (4 days old)
>> References	: http://marc.info/?l=linux-kernel&m=125501488220358&w=4
>>     
>
> I don't know what to do about this one.
>
> The user indicates that they have the vserver patches applied,
> so maybe there is some interaction with that stuff.
>   
Actually i found another oops which is very similar to the previous one.
Here, vserver is not involved, and the problem starts at drbd which 
lives in kernel space (the other oops started at ocfs2).

Both ocfs2 and drbd make heavy use of network I/O so i guess the problem 
is something in the network layer.

Anything i can do to help to debugging and solving this issue ?

Thanks
Max




--------------070700000508040107060507
Content-Type: text/plain;
 name="oops2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="oops2.txt"

[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f2c ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f2d ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f2e ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f2f ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f30 ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f31 ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f32 ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f33 ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f34 ]---
[60257.728500] ------------[ cut here ]------------
[60257.728500] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60257.728500] Hardware name: 
[60257.728500] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60257.728500] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60257.728500] Call Trace:
[60257.728500]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60257.728500]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60257.728500]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60257.728500]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60257.728500]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60257.728500]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60257.728500]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60257.728500]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60257.728500]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60257.728500]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60257.728500]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60257.728500]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60257.728500]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60257.728500]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60257.728500]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60257.728500]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60257.728500]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60257.728500]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60257.728500]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60257.728500]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60257.728500]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60257.728500]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60257.728500]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60257.728500]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60257.728500]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60257.728500]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60257.728500]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60257.728500]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60257.728500]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60257.728500]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60257.728500]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60257.728500]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60257.728500]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60257.728500]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60257.728500]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60257.728500]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60257.728500]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60257.728500]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60257.728500]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60257.728500]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60257.728500]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60257.728500]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60257.728500]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60257.728500]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60257.728500] ---[ end trace 694817acca794f35 ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f36 ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f37 ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f38 ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f39 ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f3a ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f3b ]---
[60258.036152] ------------[ cut here ]------------
[60258.036152] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60258.036152] Hardware name: 
[60258.036152] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60258.036152] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60258.036152] Call Trace:
[60258.036152]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60258.036152]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60258.036152]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60258.036152]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60258.036152]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60258.036152]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60258.036152]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60258.036152]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60258.036152]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60258.036152]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60258.036152]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60258.036152]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60258.036152]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60258.036152]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60258.036152]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60258.036152]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60258.036152]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60258.036152]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60258.036152]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60258.036152]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60258.036152]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60258.036152]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60258.036152]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60258.036152]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60258.036152]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60258.036152]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60258.036152]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60258.036152]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60258.036152]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60258.036152]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60258.036152]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60258.036152]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60258.036152]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60258.036152]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60258.036152]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60258.036152]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60258.036152]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60258.036152]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60258.036152]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60258.036152]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60258.036152]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60258.036152]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60258.036152]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60258.036152]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60258.036152] ---[ end trace 694817acca794f3c ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f3d ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f3e ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f3f ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f40 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f41 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f42 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f43 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f44 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f45 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f46 ]---
[60259.116162] ------------[ cut here ]------------
[60259.116162] WARNING: at net/core/skbuff.c:398 skb_release_head_state+0x64/0xc8()
[60259.116162] Hardware name: 
[60259.116162] Modules linked in: ocfs2 jbd2 quota_tree ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager ocfs2_stackglue crc32c netconsole configfs drbd cn loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw virtio_net pcspkr psmouse virtio_balloon parport_pc parport button processor i2c_piix4 i2c_core evdev ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod ide_cd_mod cdrom virtio_blk ata_generic ata_piix libata scsi_mod virtio_pci virtio_ring virtio piix ide_pci_generic ide_core floppy thermal fan thermal_sys
[60259.116162] Pid: 1814, comm: drbd1_receiver Tainted: G        W  2.6.31.2-vserver-navynet #1
[60259.116162] Call Trace:
[60259.116162]  <IRQ>  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81049ae1>] ? warn_slowpath_common+0x77/0xa3
[60259.116162]  [<ffffffff81253cd5>] ? skb_release_head_state+0x64/0xc8
[60259.116162]  [<ffffffff81253a1a>] ? __kfree_skb+0x9/0x7d
[60259.116162]  [<ffffffffa01e2139>] ? free_old_xmit_skbs+0x51/0x6e [virtio_net]
[60259.116162]  [<ffffffffa01e2c85>] ? start_xmit+0x26/0xf2 [virtio_net]
[60259.116162]  [<ffffffff8126934f>] ? netpoll_send_skb+0xd2/0x205
[60259.116162]  [<ffffffffa02a2216>] ? write_msg+0x90/0xeb [netconsole]
[60259.116162]  [<ffffffff81049f06>] ? __call_console_drivers+0x5e/0x6f
[60259.116162]  [<ffffffff8104a082>] ? release_console_sem+0x115/0x1ba
[60259.116162]  [<ffffffff8104a632>] ? vprintk+0x2f2/0x34b
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81308309>] ? printk+0x4e/0x5d
[60259.116162]  [<ffffffff8102b49d>] ? kvm_clock_read+0x4d/0x52
[60259.116162]  [<ffffffff81070b62>] ? getnstimeofday+0x55/0xaf
[60259.116162]  [<ffffffff81062683>] ? ktime_get_ts+0x21/0x49
[60259.116162]  [<ffffffff810626b7>] ? ktime_get+0xc/0x41
[60259.116162]  [<ffffffff81062788>] ? hrtimer_interrupt+0x9c/0x146
[60259.116162]  [<ffffffff81024a4b>] ? smp_apic_timer_interrupt+0x80/0x93
[60259.116162]  [<ffffffff81011663>] ? apic_timer_interrupt+0x13/0x20
[60259.116162]  <EOI>  [<ffffffff81157811>] ? cap_socket_recvmsg+0x0/0x3
[60259.116162]  [<ffffffff8130a9eb>] ? _spin_unlock_irq+0xd/0x31
[60259.116162]  [<ffffffff8103e6de>] ? finish_task_switch+0x5b/0xec
[60259.116162]  [<ffffffff81308f73>] ? thread_return+0x47/0xd5
[60259.116162]  [<ffffffff81293cc8>] ? tcp_current_mss+0x3f/0x5a
[60259.116162]  [<ffffffff81309213>] ? schedule_timeout+0x21/0x197
[60259.116162]  [<ffffffff8104f482>] ? local_bh_disable+0xe/0x10
[60259.116162]  [<ffffffff8130a7bf>] ? _spin_lock_bh+0x13/0x29
[60259.116162]  [<ffffffff8124f6ba>] ? release_sock+0x19/0xc3
[60259.116162]  [<ffffffff8124fd9b>] ? sk_wait_data+0x85/0xca
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff812892ab>] ? tcp_prequeue_process+0x9d/0xac
[60259.116162]  [<ffffffff8128a4ae>] ? tcp_recvmsg+0x421/0xabd
[60259.116162]  [<ffffffff8118d7cb>] ? cfq_add_rq_rb+0xd2/0xe5
[60259.116162]  [<ffffffff8124eb4a>] ? sock_common_recvmsg+0x30/0x45
[60259.116162]  [<ffffffff8124cde9>] ? sock_recvmsg+0xf7/0x18d
[60259.116162]  [<ffffffff8105f762>] ? autoremove_wake_function+0x0/0x2e
[60259.116162]  [<ffffffff8130a825>] ? _spin_lock_irqsave+0x25/0x41
[60259.116162]  [<ffffffffa0271e4d>] ? _drbd_send_cmd+0x11d/0x1eb [drbd]
[60259.116162]  [<ffffffff811851cf>] ? blk_rq_map_sg+0x12d/0x276
[60259.116162]  [<ffffffffa025c7d8>] ? drbd_recv+0x74/0x147 [drbd]
[60259.116162]  [<ffffffffa025c001>] ? drbd_may_finish_epoch+0x2c4/0x46e [drbd]
[60259.116162]  [<ffffffffa025ee5d>] ? drbd_recv_header+0x18/0xc8 [drbd]
[60259.116162]  [<ffffffffa025ef39>] ? drbdd+0x2c/0x1d6 [drbd]
[60259.116162]  [<ffffffffa026212b>] ? drbdd_init+0xf2/0x14a [drbd]
[60259.116162]  [<ffffffffa0273275>] ? drbd_thread_setup+0x16f/0x231 [drbd]
[60259.116162]  [<ffffffff81011b9a>] ? child_rip+0xa/0x20
[60259.116162]  [<ffffffff811b1e73>] ? vgacon_cursor+0x0/0x1a4
[60259.116162]  [<ffffffffa0273106>] ? drbd_thread_setup+0x0/0x231 [drbd]
[60259.116162]  [<ffffffff81011b90>] ? child_rip+0x0/0x20
[60259.116162] ---[ end trace 694817acca794f47 ]---

--------------070700000508040107060507--
