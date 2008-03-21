From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Fri, 21 Mar 2008 10:52:27 +0100
Message-ID: <47E3855B.4060304@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080321002846.GA25568@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:58081 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090AbYCUJwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 05:52:30 -0400
In-Reply-To: <20080321002846.GA25568@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski wrote:
> On Thu, Mar 20, 2008 at 11:58:35PM +0100, Bernard Pidoux wrote:
> ...
>> I recompiled the kernel after turning off the above options.
>> However there is still a kernel panic documented below.
>> Does it help ?
> 
> I wanted to see something more on the stack than lockdep's code only.
> Will see... It seems some memory debugging is still on and doing this
> poisoning with '6b', but I can't check now what it is. (Sometimes this
> could omit some warnings).
> 
> Thanks,
> Jarek P.

The only difference I can see compared to the original spinlock report 
is this line :

[<c01e7409>] _raw_spin_lock+0x69/0x140

Regards,

Bernard P.



BUG: spinlock bad magic on CPU#0, ax25ipd/3648
BUG: unable to handle kernel paging request at virtual address 6b6b6c2f
printing eip: c01e730b *pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in: rose netrom mkiss crc16 ax25 mga drm netconsole 
configfs nfsd exportfs nfs lockd nfs_acl sunrpc af_packet ipv6 
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss 
snd_mixer_oss binfmt_misc loop usb_storage scsi_mod floppy usbhid 
snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm snd_timer 
snd uhci_hcd soundcore snd_page_alloc usbcore ne2k_pci ide_cd 8390 
ac97_bus intel_agp agpgart genrtc ext3 jbd ide_disk piix ide_core

Pid: 3648, comm: ax25ipd Not tainted (2.6.24.3 #8)
EIP: 0060:[<c01e730b>] EFLAGS: 00010002 CPU: 0
EIP is at spin_bug+0xdb/0xf0
EAX: 00000032 EBX: 6b6b6b6b ECX: 6b6b6b6b EDX: 00000096
ESI: c0e4bc30 EDI: c0333633 EBP: c5c7bbc4 ESP: c5c7bba0
  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process ax25ipd (pid: 3648, ti=c5c7a000 task=c6abec90 task.ti=c5c7a000)
Stack: c0333724 c0333633 00000000 c6abee59 00000e40 00000007 c0e4bc30 
00000001
        c697ebf8 c5c7bbfc c01e7409 00000000 00000001 c0180640 00000000 
00000000
        00000003 c0a320b8 00000000 c6abec90 00000282 00000001 c697ebf8 
c5c7bc08
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
  [<c0122ae5>] local_bh_enable_ip+0x45/0x50
  [<c02c0050>] _spin_unlock_bh+0x10/0x20
  [<c8c396ca>] mkiss_receive_buf+0x36a/0x420 [mkiss]
  [<c020f037>] pty_write+0x47/0x60
  [<c020c5f9>] write_chan+0x229/0x330
  [<c0209c98>] tty_write+0x128/0x1c0
  [<c017346f>] vfs_write+0xaf/0x120
  [<c0173aad>] sys_write+0x3d/0x70
  [<c0104256>] sysenter_past_esp+0x5f/0x85
  =======================
Code: 00 64 8b 0d 08 f0 3a c0 89 44 24 0c 89 4c 24 08 89 54 24 10 89 7c 
24 04 c7 04 24 24 37 33 c0 e8 5c 6f f3 ff 85 db 8b 4e 08 74 83 <8b> 93 
c4 00 00 00 8d 83 c9 01 00 00 e9 7c ff ff ff 8d 74 26 00
EIP: [<c01e730b>] spin_bug+0xdb/0xf0 SS:ESP 0068:c5c7bba0
Kernel panic - not syncing: Fatal exception in interrupt
 

