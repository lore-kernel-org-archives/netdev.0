From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Tue, 14 Sep 2010 12:07:38 -0700
Message-ID: <20100914120738.6a658f69.akpm@linux-foundation.org>
References: <bug-18492-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, hramrach@centrum.cz,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38857 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754674Ab0INTIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 15:08:10 -0400
In-Reply-To: <bug-18492-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 14 Sep 2010 15:19:30 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=18492
> 
>            Summary: kernel softirq warning on boot
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36-rc4

Looks like a post-2.6.35 regression.  I'd be looking at the
rcu_read_unlock_bh() in netpoll_rx(), added by "netpoll: Fix RCU
usage".


>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: hramrach@centrum.cz
>         Regression: No
> 
> 
> In the 2.6.36 rc kernels I noticed a warning on every boot.
> 
> It may be related to upgrading the cpu to dual-core rather than upgrading the
> kernel.
> 
>  [   14.332011] ------------[ cut here ]------------
>  [   14.332021] WARNING: at kernel/softirq.c:143
> _local_bh_enable_ip+0x41/0x8b()
>  [   14.332024] Hardware name: System Product Name
>  [   14.332026] Modules linked in: bridge stp llc reiserfs fuse coretemp
> hwmon_vid radeonfb fb_d
> dc loop firewire_sbp2 snd_hda_codec_realtek snd_hda_intel snd_hda_codec
> snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_mid
> i snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device asus_atk0110
> snd wacom processor soundcore button psmouse lm6
> 3 snd_page_alloc led_class parport_pc i2c_i801 shpchp parport serio_raw joydev
> evdev tpm_tis pci_hotplug tpm tpm_bios rng_core 
> ext3 jbd mbcache usbhid hid sg sr_mod cdrom sd_mod crc_t10dif radeon pata_acpi
> ttm ata_generic drm_kms_helper ata_piix ehci_hcd
>  uhci_hcd drm i2c_algo_bit i2c_core libata atl1 thermal thermal_sys
> firewire_ohci usbcore mii firewire_core crc_itu_t scsi_mod 
> nls_base [last unloaded: scsi_wait_scan]
>  [   14.332101] Pid: 0, comm: swapper Not tainted 2.6.36-rc4-r600fence-amd64 #1
>  [   14.332104] Call Trace:
>  [   14.332106]  <IRQ>  [<ffffffff810442f8>] ? warn_slowpath_common+0x78/0x8c
>  [   14.332116]  [<ffffffff8104985b>] ? _local_bh_enable_ip+0x41/0x8b
>  [   14.332122]  [<ffffffff812515e5>] ? netpoll_rx+0x6d/0x79
>  [   14.332126]  [<ffffffff81253721>] ? netif_rx+0xd/0x7b
>  [   14.332130]  [<ffffffff810403a6>] ? rebalance_domains+0xd1/0x13b
>  [   14.332135]  [<ffffffff810aaf19>] ? perf_event_task_tick+0x6a/0x186
>  [   14.332146]  [<ffffffffa00c2994>] ? atl1_intr+0x8d9/0x9a5 [atl1]
>  [   14.332151]  [<ffffffff8108d68b>] ? handle_IRQ_event+0x4c/0x104
>  [   14.332156]  [<ffffffff8100e6a6>] ? read_tsc+0x5/0x16
>  [   14.332160]  [<ffffffff8108f2fb>] ? handle_edge_irq+0xd9/0x120
>  [   14.332164]  [<ffffffff8100af68>] ? handle_irq+0x17/0x1f
>  [   14.332168]  [<ffffffff8100a62a>] ? do_IRQ+0x54/0xb9
>  [   14.332173]  [<ffffffff81305093>] ? ret_from_intr+0x0/0x11
>  [   14.332175]  <EOI>  [<ffffffff8100fb50>] ? mwait_idle+0x75/0x80
>  [   14.332182]  [<ffffffff8100fb02>] ? mwait_idle+0x27/0x80
>  [   14.332187]  [<ffffffff81007b64>] ? cpu_idle+0xaa/0x120
>  [   14.332192]  [<ffffffff816bad4f>] ? start_kernel+0x3ce/0x3d9
>  [   14.332197]  [<ffffffff816ba3ba>] ? x86_64_start_kernel+0xf9/0x106
>  [   14.332200] ---[ end trace 76feca083f1d81b1 ]---
> 

