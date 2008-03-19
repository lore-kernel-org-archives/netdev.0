From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Wed, 19 Mar 2008 21:57:18 +0100
Message-ID: <47E17E2E.9050105@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:36371 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbYCTBB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 21:01:27 -0400
In-Reply-To: <47E0C261.3000106@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Bernard Pidoux F6BVP wrote:
> 
> Francois Romieu wrote:
>> Bernard Pidoux F6BVP <f6bvp@free.fr> :
>> [...]
>>> I used netconsole to document a kernel panic related to AX25 on one 
>>> of my systems.
>>> This occurs systematically as soon as I close an AX25 session 
>>> established through a level 3 ROSE network (FPAC) via AXUDP link 
>>> (ax25ipd).
>>> It is not triggered when connecting locally or via AX25 call through 
>>> LAN.
>>
>> May be replacing netif_rx() in drivers/net/hamradio/mkiss.c::ax_bump()
>> by netif_receive_skb() ?
>>
> 
> Sorry, this does not made it.
> I replaced netif_rx() by netif_receive_skb(skb)
> but this gives a worst situation : system is frozen.
> Thank you for the suggestion.
> 
>  =======================
> BUG: soft lockup - CPU#0 stuck for 11s! [ax25ipd:3584]
> 
> Pid: 3584, comm: ax25ipd Not tainted (2.6.24.3 #7)
> EIP: 0060:[<c01ed892>] EFLAGS: 00000246 CPU: 0
> EIP is at delay_tsc+0x12/0x20
> EAX: 7752234b EBX: 00000001 ECX: 7752234b EDX: 00000016
> ESI: 087022c8 EDI: 00000000 EBP: c6bb5bc0 ESP: c6bb5bbc
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> CR0: 8005003b CR2: b7dd86f8 CR3: 07960000 CR4: 000000d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
>  [<c010535a>] show_trace_log_lvl+0x1a/0x30
>  [<c0105d82>] show_trace+0x12/0x20
>  [<c01024cc>] show_regs+0x1c/0x20
>  [<c015555b>] softlockup_tick+0x11b/0x150
>  [<c0126c12>] run_local_timers+0x12/0x20
>  [<c012708f>] update_process_times+0x2f/0x60
>  [<c013a355>] tick_periodic+0x25/0x80
>  [<c013a3c9>] tick_handle_periodic+0x19/0x80
>  [<c0107aca>] timer_interrupt+0x4a/0x60
>  [<c0155928>] handle_IRQ_event+0x28/0x60
>  [<c015725f>] handle_level_irq+0x7f/0xf0
>  [<c0106e68>] do_IRQ+0x48/0xa0
>  [<c0104d16>] common_interrupt+0x2e/0x34
>  [<c01ed839>] __delay+0x9/0x10
>  [<c01f15f2>] _raw_spin_lock+0xb2/0x140
>  [<c02cd350>] _spin_lock_bh+0x50/0x60
>  [<c8c59e72>] ax_xmit+0x112/0x370 [mkiss]
>  [<c025e947>] dev_hard_start_xmit+0x207/0x270
>  [<c026f454>] __qdisc_run+0x54/0x1b0
>  [<c0261226>] dev_queue_xmit+0x266/0x340
>  [<c8c27a87>] ax25_queue_xmit+0x47/0x70 [ax25]
>  [<c8c27b77>] ax25_transmit_buffer+0xc7/0x110 [ax25]
>  [<c8c27c3d>] ax25_send_iframe+0x7d/0x110 [ax25]
>  [<c8c27d80>] ax25_kick+0xb0/0x1b0 [ax25]
>  [<c8c28e49>] ax25_std_frame_in+0x69/0x890 [ax25]
>  [<c8c26dbb>] ax25_kiss_rcv+0x2bb/0x7c0 [ax25]
>  [<c025e24a>] netif_receive_skb+0x38a/0x480
>  [<c8c596ab>] mkiss_receive_buf+0x34b/0x420 [mkiss]
>  [<c0219457>] pty_write+0x47/0x60
>  [<c0216a19>] write_chan+0x229/0x330
>  [<c021407b>] tty_write+0x12b/0x1c0
>  [<c017b66f>] vfs_write+0xaf/0x120
>  [<c017bcbd>] sys_write+0x3d/0x70
>  [<c010427e>] sysenter_past_esp+0x5f/0xa5
>  =======================
> 
> Regards,
> 
> Bernard Pidoux
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

I also tried to revert Jarek's mkiss ax_bump() patch, but this did not 
prevent
kernel lockup, although this time swapper is involved and not ax25ipd.

Bernard Pidoux



BUG: unable to handle kernel paging request at virtual address 6b6b6c2b
printing eip: c013fc67 *pde = 00000000
Oops: 0002 [#1] SMP
Modules linked in: rose netrom mkiss crc16 ax25 mga netconsole drm 
configfs nfsd exportfs nfs lockd nfs_acl sunrpc af_packet ipv6 
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss 
snd_mixer_oss binfmt_misc loop usb_storage scsi_mod floppy usbhid 
snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm snd_timer 
snd uhci_hcd soundcore usbcore snd_page_alloc ne2k_pci ide_cd ac97_bus 
intel_agp 8390 agpgart genrtc ext3 jbd ide_disk piix ide_core

Pid: 0, comm: swapper Not tainted (2.6.24.3 #7)
EIP: 0060:[<c013fc67>] EFLAGS: 00010012 CPU: 0
EIP is at __lock_acquire+0x67/0x1170
EAX: 00000002 EBX: 00000001 ECX: c7657030 EDX: 00000002
ESI: 6b6b6b6b EDI: 00000000 EBP: c0395c84 ESP: c0395c00
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0394000 task=c036a3c0 task.ti=c0394000)
Stack: 0000600c 00000000 030061f9 00000000 c0514298 030061f9 00000000 
c0395ca8
        c013fe71 c0395cb0 c013fe71 00000001 000001e2 00000000 00000002 
00000000
        c7657030 c036a3c0 030061e2 00000000 c0510ba8 030061e2 000001f9 
00000002
Call Trace:
  [<c010535a>] show_trace_log_lvl+0x1a/0x30
  [<c0105419>] show_stack_log_lvl+0xa9/0xd0
  [<c0105507>] show_registers+0xc7/0x1b0
  [<c01056fa>] die+0x10a/0x230
  [<c01146f0>] do_page_fault+0x160/0x630
  [<c02cdaea>] error_code+0x72/0x78
  [<c0140df5>] lock_acquire+0x85/0xa0
  [<c02cd79e>] _spin_lock_irqsave+0x3e/0x70
  [<c0117c4b>] __wake_up+0x1b/0x50
  [<c025689c>] sock_def_write_space+0x9c/0xc0
  [<c0256c9c>] sock_wfree+0x3c/0x50
  [<c0258ef7>] skb_release_all+0x57/0x130
  [<c025868b>] __kfree_skb+0xb/0x90
  [<c0258729>] kfree_skb+0x19/0x40
  [<c8cc1e23>] ax25_frames_acked+0x43/0x70 [ax25]
  [<c8cc11db>] ax25_std_frame_in+0x3fb/0x890 [ax25]
  [<c8cbedbb>] ax25_kiss_rcv+0x2bb/0x7c0 [ax25]
  [<c025e24a>] netif_receive_skb+0x38a/0x480
  [<c0260e9b>] process_backlog+0x7b/0xf0
  [<c02609a7>] net_rx_action+0x167/0x210
  [<c0122da3>] __do_softirq+0x93/0x120
  [<c0122e87>] do_softirq+0x57/0x60
  [<c0123235>] irq_exit+0x85/0x90
  [<c0106e6d>] do_IRQ+0x4d/0xa0
  [<c0104d16>] common_interrupt+0x2e/0x34
  [<c0102606>] cpu_idle+0x76/0xa0
  [<c02ca6a9>] rest_init+0x49/0x50
  [<c0399d75>] start_kernel+0x2d5/0x360
  [<00000000>] 0x0
  =======================
Code: 9c 58 f6 c4 02 0f 85 ff 05 00 00 83 ff 07 0f 87 28 06 00 00 85 ff 
0f 85 ac 03 00 00 8b 4d bc 8b 71 04 85 f6 0f 84 9e 03 00 00 90 <ff> 86 
c0 00 00 00 89 f0 e8 bc c8 ff ff 85 c0 0f 85 84 02 00 00
EIP: [<c013fc67>] __lock_acquire+0x67/0x1170 SS:ESP 0068:c0395c00
Kernel panic - not syncing: Fatal exception in interrupt

