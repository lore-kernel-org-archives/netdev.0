From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.26] OOPS in __linkwatch_run_queue (unable to handle kernel
 NULL pointer dereference at 00000235)
Date: Thu, 30 Oct 2008 02:09:10 -0700
Message-ID: <20081030020910.f97ee3fc.akpm@linux-foundation.org>
References: <20081027150001.GQ8318@vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Folkert van Heusden <folkert@vanheusden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43093 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753271AbYJ3JJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 05:09:17 -0400
In-Reply-To: <20081027150001.GQ8318@vanheusden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Mon, 27 Oct 2008 16:00:02 +0100 Folkert van Heusden <folkert@vanheusden.com> wrote:

> Hi,                                                                                                                                                                                                
>                                                                                                                                                                                                    
> While running my http://vanheusden.com/pyk/ script (which randomly
> inserts and removes modules) I triggered the folllowing oops in a 2.6.26
> kernel on a pre-ht pentium 4 (hp pavillion laptop type zv5231ea):
> 
> [ 1037.480097] BUG: unable to handle kernel NULL pointer dereference at 00000235
> [ 1037.480188] IP: [<c0261078>] __linkwatch_run_queue+0x6d/0x15a
> [ 1037.480256] *pde = 00000000
> [ 1037.480315] Oops: 0000 [#1] SMP
> [ 1037.480393] Modules linked in: pcspkr(+) dm_snapshot joydev cdrom cpufreq_conservative snd_atiixp_modem(+) ohci_hcd(+) serio_raw wmi loop i2c_piix4 button ac sbp2 parport_pc lp psmouse output snd_seq_device pci_hotplug arc4 ecb crypto_blkcipher b43legacy input_polldev led_class rng_core rfkill_input rfkill cpufreq_stats ssb pcmcia firmware_class mac80211 parport cpufreq_ondemand dm_mirror i2c_core freq_table cfg80211 dm_log snd_ac97_codec ac97_bus ieee1394 scsi_mod snd_pcm snd_timer yenta_socket rsrc_nonstatic snd_page_alloc radeon drm rfcomm l2cap bluetooth ipv6 snd soundcore ati_agp agpgart evdev ext3 jbd mbcache dm_mod ide_disk 8139cp atiixp 8139too mii pcmcia_core ide_pci_generic ide_core usbcore processor thermal_sys [last unloaded: b44]
> [ 1037.482294]
> [ 1037.482328] Pid: 6, comm: events/0 Not tainted (2.6.26-1-686 #1)
> [ 1037.482365] EIP: 0060:[<c0261078>] EFLAGS: 00010246 CPU: 0
> [ 1037.482403] EIP is at __linkwatch_run_queue+0x6d/0x15a
> [ 1037.482439] EAX: f744c000 EBX: 00000001 ECX: c03632a4 EDX: 01553000
> [ 1037.482476] ESI: 00000003 EDI: 00000000 EBP: 00000001 ESP: f744df94
> [ 1037.482536]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [ 1037.482572] Process events/0 (pid: 6, ti=f744c000 task=f743e460 task.ti=f744c000)
> [ 1037.482609] Stack: f7414600 c03632a0 c0261165 00000000 c0261182 c012edee f7414600 c012f4c9
> [ 1037.482855]        f741460c c012f57c 00000000 f743e460 c013177c f744dfc8 f744dfc8 f7414600
> [ 1037.483101]        00000000 c01316bb c0131683 00000000 c01044f3 f7441ef8 00000000 00000000
> [ 1037.483346] Call Trace:
> [ 1037.483412]  [<c0261165>] linkwatch_event+0x0/0x22
> [ 1037.483474]  [<c0261182>] linkwatch_event+0x1d/0x22
> [ 1037.483534]  [<c012edee>] run_workqueue+0x74/0xf2
> [ 1037.483596]  [<c012f4c9>] worker_thread+0x0/0xbd
> [ 1037.483656]  [<c012f57c>] worker_thread+0xb3/0xbd
> [ 1037.483718]  [<c013177c>] autoremove_wake_function+0x0/0x2d
> [ 1037.483785]  [<c01316bb>] kthread+0x38/0x5d
> [ 1037.483842]  [<c0131683>] kthread+0x0/0x5d
> [ 1037.483901]  [<c01044f3>] kernel_thread_helper+0x7/0x10
> [ 1037.483974]  =======================
> [ 1037.484007] Code: 80 05 00 8b 1d 9c b5 41 c0 c7 05 9c b5 41 c0 00 00 00 00 90 fe 05 90 b5 41 c0 fb 0f 1f 84 00 00 00 00 00 90 e9 ce 00 00 00 85 ff <8b> ab 34 02 00 00 74 17 89 d8 e8 7d fe ff ff 85 c0 75 0c 89 d8
> [ 1037.484013] EIP: [<c0261078>] __linkwatch_run_queue+0x6d/0x15a SS:ESP 0068:f744df94
> [ 1037.485642] ---[ end trace 69e935fd5d0e15c9 ]---
> 
> 
> Folkert van Heusden

