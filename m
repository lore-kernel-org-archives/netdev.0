From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [AX25] kernel panic
Date: Tue, 18 Mar 2008 11:44:49 +0100
Message-ID: <47DF9D21.20807@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:53777 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbYCRKow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 06:44:52 -0400
Received: from smtp5-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 872983F616C
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 11:44:51 +0100 (CET)
Received: from [192.168.0.66] (car75-2-82-66-61-83.fbx.proxad.net [82.66.61.83])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 2F44C3F6315
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 11:44:50 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I used netconsole to document a kernel panic related to AX25 on one of 
my systems.
This occurs systematically as soon as I close an AX25 session 
established through a level 3 ROSE network (FPAC) via AXUDP link (ax25ipd).
It is not triggered when connecting locally or via AX25 call through LAN.

This is observed with kernel-2.6.24.2 and -3 with most recent AX25 
patches applied.

Bernard Pidoux


BUG: unable to handle kernel paging request at virtual address 6b6b6c2b
printing eip: c0139585 *pde = 00000000
Oops: 0002 [#1]
Modules linked in: netconsole configfs rose netrom mkiss crc16 ax25 mga 
drm nfsd exportfs nfs lockd nfs_acl sunrpc af_packet ipv6 snd_seq_dummy 
snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss 
binfmt_misc loop floppy usbhid snd_ens1371 snd_rawmidi snd_seq_device 
snd_ac97_codec snd_pcm uhci_hcd snd_timer snd soundcore snd_page_alloc 
usbcore ne2k_pci intel_agp ac97_bus ide_cd 8390 agpgart ext3 jbd 
ide_disk piix ide_core

Pid: 3527, comm: ax25ipd Not tainted (2.6.24.2 #2)
EIP: 0060:[<c0139585>] EFLAGS: 00010012 CPU: 0
EIP is at __lock_acquire+0x65/0x11d0
EAX: 00000012 EBX: 00000001 ECX: c7670068 EDX: 00000002
ESI: 00000000 EDI: 6b6b6b6b EBP: c6bf5bc0 ESP: c6bf5b38
  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process ax25ipd (pid: 3527, ti=c6bf4000 task=c60251d0 task.ti=c6bf4000)
Stack: 0000580b 00000000 02c059e8 00000000 c04f73d8 02c059e8 00000000 
c6bf5be4
        c01397d8 00000001 c017ecc0 00000000 00000002 00000000 c7670068 
c60251d0
        0000580b 00000000 02c059d1 00000000 c04f3ce0 00000002 00000000 
c75290f8
Call Trace:
  [<c010513a>] show_trace_log_lvl+0x1a/0x30
  [<c01051f9>] show_stack_log_lvl+0xa9/0xd0
  [<c01052e6>] show_registers+0xc6/0x1b0
  [<c01054b5>] die+0xe5/0x220
  [<c011244f>] do_page_fault+0x15f/0x610
  [<c02c2cfa>] error_code+0x6a/0x70
  [<c013a773>] lock_acquire+0x83/0xa0
  [<c02c2abe>] _spin_lock_irqsave+0x3e/0x70
  [<c011458b>] __wake_up+0x1b/0x50
  [<c024d56c>] sock_def_write_space+0x9c/0xc0
  [<c024d96a>] sock_wfree+0x3a/0x40
  [<c024fb61>] skb_release_all+0x51/0x120
  [<c024f30b>] __kfree_skb+0xb/0x90
  [<c024f3a9>] kfree_skb+0x19/0x30
  [<c8c19e03>] ax25_frames_acked+0x43/0x70 [ax25]
  [<c8c17a10>] ax25_check_iframes_acked+0x40/0x60 [ax25]
  [<c8c1946f>] ax25_std_frame_in+0x6af/0x890 [ax25]
  [<c8c16dba>] ax25_kiss_rcv+0x2ba/0x7b0 [ax25]
  [<c0254e89>] netif_receive_skb+0x379/0x470
  [<c0257a85>] process_backlog+0x75/0xe0
  [<c025759b>] net_rx_action+0x12b/0x1d0
  [<c011d595>] __do_softirq+0x55/0xc0
  [<c011d647>] do_softirq+0x47/0x50
  [<c011d9f5>] local_bh_enable_ip+0x95/0xe0
  [<c02c24b5>] _spin_unlock_bh+0x25/0x30
  [<c8c0c6b0>] mkiss_receive_buf+0x360/0x420 [mkiss]
  [<c020e077>] pty_write+0x47/0x60
  [<c020b642>] write_chan+0x222/0x330
  [<c0208d06>] tty_write+0x126/0x1b0
  [<c01727ff>] vfs_write+0xaf/0x120
  [<c0172d4d>] sys_write+0x3d/0x70
  [<c010412a>] sysenter_past_esp+0x5f/0xa5
  =======================
Code: 00 9c 58 f6 c4 02 0f 85 52 06 00 00 83 fe 07 0f 87 7b 06 00 00 85 
f6 0f 85 fe 03 00 00 8b 4d b0 8b 79 04 85 ff 0f 84 f0 03 00 00 <ff> 87 
c0 00 00 00 89 f8 e8 ce c9 ff ff 85 c0 0f 85 d6 02 00 00
EIP: [<c0139585>] __lock_acquire+0x65/0x11d0 SS:ESP 0068:c6bf5b38
Kernel panic - not syncing: Fatal exception in interrupt
 


