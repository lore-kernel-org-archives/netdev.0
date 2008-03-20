From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Thu, 20 Mar 2008 23:58:35 +0100
Message-ID: <47E2EC1B.9070405@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:48179 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbYCTW6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 18:58:40 -0400
In-Reply-To: <20080320073021.GA4037@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski wrote:
> On Wed, Mar 19, 2008 at 09:57:18PM +0100, Bernard Pidoux wrote:
> ...
>> I also tried to revert Jarek's mkiss ax_bump() patch, but this did not  
>> prevent
>> kernel lockup, although this time swapper is involved and not ax25ipd.
> ...
>> BUG: unable to handle kernel paging request at virtual address 6b6b6c2b
>> printing eip: c013fc67 *pde = 00000000
>> Oops: 0002 [#1] SMP
> 
> Well, the rest looks very similarly and not trivial... Probably a
> socket is destructed too soon (or something...). Could you try to
> reproduce this with some debugging turned off, e.g.:
> CONFIG_DEBUG_LOCK_ALLOC, CONFIG_DEBUG_PAGEALLOC, (CONFIG_SLUB_DEBUG?).
> 
> Regards,
> Jarek P.

I recompiled the kernel after turning off the above options.
However there is still a kernel panic documented below.
Does it help ?

Bernard Pidoux



BUG: spinlock bad magic on CPU#0, swapper/0
BUG: unable to handle kernel paging request at virtual address 6b6b6c2f
printing eip: c01e730b *pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in: rose netrom mkiss crc16 ax25 mga drm netconsole 
configfs nfsd exportfs nfs lockd nfs_acl sunrpc af_packet ipv6 
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss 
snd_mixer_oss binfmt_misc loop usb_storage scsi_mod floppy usbhid 
snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm snd_timer 
snd uhci_hcd intel_agp ne2k_pci ide_cd usbcore soundcore snd_page_alloc 
ac97_bus 8390 agpgart genrtc ext3 jbd ide_disk piix ide_core

Pid: 0, comm: swapper Not tainted (2.6.24.3 #8)
EIP: 0060:[<c01e730b>] EFLAGS: 00010002 CPU: 0
EIP is at spin_bug+0xdb/0xf0
EAX: 0000002f EBX: 6b6b6b6b ECX: 6b6b6b6b EDX: 00000082
ESI: c07e5a38 EDI: c0333633 EBP: c0379c78 ESP: c0379c54
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0378000 task=c0353340 task.ti=c0378000)
Stack: c0333724 c0333633 00000000 c0353509 00000000 00000010 c07e5a38 
00000001
        c7b8abb8 c0379cb0 c01e7409 c11448c8 c1147740 00000000 c11448c0 
c0379cb8
        c114775c c11448c8 c1147740 00000000 00000282 00000001 c7b8abb8 
c0379cbc
Call Trace:
  [<c010527a>] show_trace_log_lvl+0x1a/0x30
  [<c0105339>] show_stack_log_lvl+0xa9/0xd0
  [<c0105427>] show_registers+0xc7/0x1b0
  [<c010561a>] die+0x10a/0x230
  [<c0114855>] do_page_fault+0x2f5/0x600
  [<c02c039a>] error_code+0x72/0x78
  [<c01e7409>] _raw_spin_lock+0x69/0x140
  [<c02c01cc>] _spin_lock_irqsave+0xc/0x20
  [<c0117c9b>] __wake_up+0x1b/0x50
  [<c024badc>] sock_def_write_space+0x9c/0xc0
  [<c024bdcc>] sock_wfree+0x3c/0x50
  [<c024dfc7>] skb_release_all+0x57/0x130
  [<c024d75b>] __kfree_skb+0xb/0x90
  [<c024d7f9>] kfree_skb+0x19/0x40
  [<c8c49e33>] ax25_frames_acked+0x43/0x70 [ax25]
  [<c8c47a30>] ax25_check_iframes_acked+0x40/0x60 [ax25]
  [<c8c4949f>] ax25_std_frame_in+0x6af/0x890 [ax25]
  [<c8c46dbb>] ax25_kiss_rcv+0x2bb/0x7c0 [ax25]
  [<c02531eb>] netif_receive_skb+0x33b/0x420
  [<c0255c1b>] process_backlog+0x6b/0xd0
  [<c025573f>] net_rx_action+0xff/0x1a0
  [<c0122864>] __do_softirq+0x84/0x100
  [<c012291b>] do_softirq+0x3b/0x50
  [<c0122b69>] irq_exit+0x79/0x90
  [<c0106d46>] do_IRQ+0x46/0x80
  [<c0104c67>] common_interrupt+0x23/0x28
  [<c01025f6>] cpu_idle+0x76/0xa0
  [<c02bd8e9>] rest_init+0x49/0x50
  [<c037dd55>] start_kernel+0x2b5/0x330
  [<00000000>] 0x0
  =======================
Code: 00 64 8b 0d 08 f0 3a c0 89 44 24 0c 89 4c 24 08 89 54 24 10 89 7c 
24 04 c7 04 24 24 37 33 c0 e8 5c 6f f3 ff 85 db 8b 4e 08 74 83 <8b> 93 
c4 00 00 00 8d 83 c9 01 00 00 e9 7c ff ff ff 8d 74 26 00
EIP: [<c01e730b>] spin_bug+0xdb/0xf0 SS:ESP 0068:c0379c54
Kernel panic - not syncing: Fatal exception in interrupt
 

