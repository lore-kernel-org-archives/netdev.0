From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bug 14749] New: Kernel locks up after a few minutes of heavy
 surfing
Date: Mon, 7 Dec 2009 09:05:31 -0800
Message-ID: <20091207090531.4fc92d65@nehalam>
References: <20091207090154.6bbfe8e2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43693 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935489AbZLGRFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 12:05:45 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 8E5784F4030
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2009 09:05:52 -0800 (PST)
In-Reply-To: <20091207090154.6bbfe8e2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Dec 2009 09:01:54 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> 
> 
> Begin forwarded message:
> 
> Date: Sun, 6 Dec 2009 13:40:19 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=14749
> 
>            Summary: Kernel locks up after a few minutes of heavy surfing
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31.6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: rankincj@yahoo.com
>         Regression: Yes
> 
> 
> Created an attachment (id=24049)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24049)
> Warnings found in kernel, relating to network corruption.
> 
> This bug is new as of 2.6.31.x kernels. After a short period of heavy surfing
> (e.g. lots of tabs open in Firefox), the kernel will suddenly stop responding.
> Nothing is written to the serial console, and the machine stops responding to
> pings. My only clue so far has been a warning which I found once in my dmesg
> log (attached).
> 
> I have already tried manually applying this patch from the upcoming -stable
> queue:
> 
> net-fix-sk_forward_alloc-corruption.patch
> 
> to no effect.
> 
> I am currently switching back to Fedora's 2.6.31.6-145.fc12.i686 kernel to see
> if it is more stable. (I cannot trust 2.6.31.6 any more.)
> 

Putting attachment inline since then developers are more likely to read it

-----------[ cut here ]------------
WARNING: at /home/chris/LINUX/linux-2.6.31/net/core/stream.c:202 inet_csk_destroy_sock+0x77/0xd3()
Hardware name: Precision WorkStation 650
Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nfsd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer firewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_util_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcache sr_mod cdrom sd_mo
 d pata_acpi sata_sil uhci_hcd ata_piix libata scsi_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agpgart i2c_algo_bit cfbcopyarea cfbimgblt
cfbfillrect [last unloaded: processor]
Pid: 32056, comm: rpm Not tainted 2.6.31.6 #1
Call Trace:
[<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
[<c1023bc6>] ? warn_slowpath_null+0xb/0xd
[<c11871ca>] ? inet_csk_destroy_sock+0x77/0xd3
[<c119188f>] ? tcp_rcv_state_process+0x81f/0x9e8
[<c11966c3>] ? tcp_v4_do_rcv+0x128/0x16d
[<c1196b0d>] ? tcp_v4_rcv+0x405/0x640
[<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
[<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
[<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
[<c116b7c5>] ? netif_receive_skb+0x261/0x281
[<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
[<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
[<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
[<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
[<c11c769b>] ? _spin_lock_irq+0xe/0x24
[<c116bce5>] ? net_rx_action+0x57/0xfd
[<c1027ea3>] ? __do_softirq+0x7a/0xe3
[<c1027e29>] ? __do_softirq+0x0/0xe3
<IRQ> [<c1027c3c>] ? irq_exit+0x29/0x63
[<c1004320>] ? do_IRQ+0x7c/0x8d
[<c1002f29>] ? common_interrupt+0x29/0x30
---[ end trace e643d9455a26ccf3 ]---
------------[ cut here ]------------
WARNING: at /home/chris/LINUX/linux-2.6.31/net/ipv4/af_inet.c:151 inet_sock_destruct+0xd8/0x138()
Hardware name: Precision WorkStation 650
Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nfsd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer firewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_util_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcache sr_mod cdrom sd_mo
 d pata_acpi sata_sil uhci_hcd ata_piix libata scsi_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agpgart i2c_algo_bit cfbcopyarea cfbimgblt
cfbfillrect [last unloaded: processor]
Pid: 32056, comm: rpm Tainted: G W 2.6.31.6 #1
Call Trace:
[<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
[<c1023bc6>] ? warn_slowpath_null+0xb/0xd
[<c11a1414>] ? inet_sock_destruct+0xd8/0x138
[<c1163243>] ? __sk_free+0x10/0xa2
[<c1196b4a>] ? tcp_v4_rcv+0x442/0x640
[<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
[<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
[<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
[<c116b7c5>] ? netif_receive_skb+0x261/0x281
[<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
[<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
[<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
[<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
[<c11c769b>] ? _spin_lock_irq+0xe/0x24
[<c116bce5>] ? net_rx_action+0x57/0xfd
[<c1027ea3>] ? __do_softirq+0x7a/0xe3
[<c1027e29>] ? __do_softirq+0x0/0xe3
<IRQ> [<c1027c3c>] ? irq_exit+0x29/0x63
[<c1004320>] ? do_IRQ+0x7c/0x8d
[<c1002f29>] ? common_interrupt+0x29/0x30
---[ end trace e643d9455a26ccf4 ]---
------------[ cut here ]------------
WARNING: at /home/chris/LINUX/linux-2.6.31/net/ipv4/af_inet.c:154 inet_sock_destruct+0x11e/0x138()
Hardware name: Precision WorkStation 650
Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nfsd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer firewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_util_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcache sr_mod cdrom sd_mo
 d pata_acpi sata_sil uhci_hcd ata_piix libata scsi_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agpgart i2c_algo_bit cfbcopyarea cfbimgblt
cfbfillrect [last unloaded: processor]
Pid: 32056, comm: rpm Tainted: G W 2.6.31.6 #1
Call Trace:
[<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
[<c1023bc6>] ? warn_slowpath_null+0xb/0xd
[<c11a145a>] ? inet_sock_destruct+0x11e/0x138
[<c1163243>] ? __sk_free+0x10/0xa2
[<c1196b4a>] ? tcp_v4_rcv+0x442/0x640
[<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
[<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
[<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
[<c116b7c5>] ? netif_receive_skb+0x261/0x281
[<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
[<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
[<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
[<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
[<c11c769b>] ? _spin_lock_irq+0xe/0x24
[<c116bce5>] ? net_rx_action+0x57/0xfd
[<c1027ea3>] ? __do_softirq+0x7a/0xe3
[<c1027e29>] ? __do_softirq+0x0/0xe3
<IRQ> [<c1027c3c>] ? irq_exit+0x29/0x63
[<c1004320>] ? do_IRQ+0x7c/0x8d
[<c1002f29>] ? common_interrupt+0x29/0x30
---[ end trace e643d9455a26ccf5 ]---


-- 
