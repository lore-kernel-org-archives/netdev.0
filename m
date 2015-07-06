From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Mon, 6 Jul 2015 13:53:17 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1507061349550.1501@localhost.localdomain>
References: <1435787748-30393-1-git-send-email-mrkiko.rs@gmail.com> <alpine.LNX.2.20.1507051219280.12595@archiso.lan> <1436177296.8225.25.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1436177296.8225.25.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sure Oliver!
Here it is.

And - I tried with various approach. I tired also kzallocating the needed 
memory inside the tx_fixup function using the GFP_ATOMIC flag due to the fact I 
am in an interrupt handler.
At some point, the problem started manifesting in a memset call that whasn't in 
my patch, DOH. Tell me if I can do something and I'll try. No crashdump 
possible it seems, after this crash the system isn't able to kexec.


Enrico Mioso


Trace: from a 32-bit QEMU VM launched with parameters:
qemu-system-i386 -drive file=dsksys.img,index=0,media=disk -boot d -m 512 -soundhw hda -cdrom torrent_ctl/archlinux-2015.06.01-dual.iso -usb -usbdevice host:12d1:1506 -redir tcp:2200::22 -machine accel=kvm,kernel_irqchip=on -serial stdio -display none -cpu host -watchdog i6300esb $@

Host is also a 32-bit system.

All goes well until I start "rtorrent" so that it emits DHT traffic (udp, small 
packets, lots of them I think).

[  617.581100] EXT4-fs (sda): re-mounted. Opts: nobarrier,noauto_da_alloc

[  656.964399] BUG: unable to handle kernel paging request at d1402000

[  656.966824] IP: [<c12596f0>] memset+0x10/0x20

[  656.966824] *pde = 1e7c1067 *pte = 11402161

[  656.966824] Oops: 0003 [#1] PREEMPT SMP

[  656.966824] Modules linked in: huawei_cdc_ncm cdc_ncm mousedev snd_hda_codec_generic ppdev bochs_drm ttm snd_hda_intel
cfg80211 drm_kms_helper rfkill snd_hda_controller snd_hda_codec psmouse pcspkr serio_raw snd_hwdep drm snd_pcm option snd_timer
usb_wwan syscopyarea usbserial snd sysfillrect sysimgblt soundcore i2c_piix4 i6300esb i2c_core parport_pc parport acpi_cpufreq e
vdev processor mac_hid sch_fq_codel nfs lockd grace sunrpc fscache ext4 crc16 mbcache jbd2 dm_snapshot dm_bufio dm_mod squashfs
loop uas cdc_wdm isofs usbnet mii usb_storage sr_mod cdrom sd_mod ata_generic pata_acpi atkbd libps2 ata_piix uhci_hcd ehci_hcd
libata intel_agp intel_gtt usbcore e1000 scsi_mod usb_common agpgart floppy i8042 serio button [last unloaded: cdc_ncm]

[  656.966824] CPU: 0 PID: 1664 Comm: main Tainted: GF               4.0.4-2-ARCH #1

[  656.966824] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150617_082717-anatol 04/01/2014

[  656.966824] task: dd48c660 ti: d1722000 task.ti: d1722000

[  656.966824] EIP: 0060:[<c12596f0>] EFLAGS: 00210246 CPU: 0

[  656.966824] EIP is at memset+0x10/0x20

[  656.966824] EAX: 00000000 EBX: ced5b058 ECX: fd959000 EDX: 00000000

[  656.966824] ESI: dd216c00 EDI: d1402000 EBP: d1723aa8 ESP: d1723aa0

[  656.966824]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068

[  656.966824] CR0: 80050033 CR2: d1402000 CR3: 11730000 CR4: 000007c0

[  656.966824] Stack:

[  656.966824]  00000025 ffffffa8 d1723ae8 e0dff758 00001000 ced6ad40 dea13500 00000002

[  656.966824]  0000006a 00000004 00000002 ced5a000 002500ff dd2bbd80 000000ac dd216c94

[  656.966824]  dd2bbb40 ced6ad40 d1723afc e0dff9d4 dd2bbb40 e0dff9a0 ced6a800 d1723b48

[  656.966824] Call Trace:

[  656.966824]  [<e0dff758>] cdc_ncm_fill_tx_frame+0x4c8/0x690 [cdc_ncm]

[  656.966824]  [<e0dff9d4>] cdc_ncm_tx_fixup+0x34/0x70 [cdc_ncm]

[  656.966824]  [<e0dff9a0>] ? cdc_ncm_bind+0x80/0x80 [cdc_ncm]

[  656.966824]  [<e08f3a50>] usbnet_start_xmit+0x60/0x7c0 [usbnet]

[  656.966824]  [<c13bce5b>] ? netif_skb_features+0xcb/0x440

[  656.966824]  [<c13ab87a>] ? __alloc_skb+0x6a/0x1e0

[  656.966824]  [<c13bd6b4>] dev_hard_start_xmit+0x224/0x3b0

[  656.966824]  [<c13bd1e5>] ? validate_xmit_skb.isra.33.part.34+0x15/0x2c0

[  656.966824]  [<c13da960>] sch_direct_xmit+0x100/0x1f0

[  656.966824]  [<c13bda12>] __dev_queue_xmit+0x1d2/0x500

[  656.966824]  [<c13d99b0>] ? ether_setup+0x80/0x80

[  656.966824]  [<c13bdd4f>] dev_queue_xmit+0xf/0x20

[  656.966824]  [<c13c744f>] neigh_resolve_output+0xff/0x200

[  656.966824]  [<c13f321a>] ip_finish_output+0x2ba/0x980

[  656.966824]  [<c13f5754>] ? __ip_make_skb+0x2a4/0x3b0

[  656.966824]  [<c13f4ec7>] ip_output+0x87/0xd0

[  656.966824]  [<c13f460c>] ? __ip_local_out+0x2c/0x80

[  656.966824]  [<c13f5a19>] ? ip_make_skb+0xd9/0x100

[  656.966824]  [<c13f4687>] ip_local_out_sk+0x27/0x30

[  656.966824]  [<c13f5874>] ip_send_skb+0x14/0x80

[  656.966824]  [<c141b0f1>] udp_send_skb+0x101/0x260

[  656.966824]  [<c141c656>] udp_sendmsg+0x2e6/0x900

[  656.966824]  [<c13f3a80>] ? ip_reply_glue_bits+0x80/0x80

[  656.966824]  [<c107f1c7>] ? update_cfs_rq_blocked_load+0x157/0x1a0

[  656.966824]  [<c1427525>] inet_sendmsg+0x75/0xa0

[  656.966824]  [<c13a213f>] do_sock_sendmsg+0x4f/0x80

[  656.966824]  [<c13a409f>] SyS_sendto+0x18f/0x1d0

[  656.966824]  [<c13a1feb>] ? sock_poll+0xeb/0x100

[  656.966824]  [<c11c5a40>] ? ep_read_events_proc+0xb0/0xb0

[  656.966824]  [<c11c5adf>] ? ep_send_events_proc+0x9f/0x1b0

[  656.966824]  [<c13a4c4c>] SyS_socketcall+0x19c/0x300

[  656.966824]  [<c14a0c97>] sysenter_do_call+0x12/0x12

[  656.966824] Code: 8a 0e 88 0f 8d b4 26 00 00 00 00 8b 45 f0 83 c4 04 5b 5e 5f 5d c3 90 8d 74 26 00 55 89 e5 57 53 3e 8d 74 26
  00 89 c3 89 c7 89 d0 <f3> aa 89 d8 5b 5f 5d c3 90 90 90 90 90 90 90 90 55 89 e5 3e 8d

[  656.966824] EIP: [<c12596f0>] memset+0x10/0x20 SS:ESP 0068:d1723aa0

[  656.966824] CR2: 00000000d1402000

[  656.966824] BUG: unable to handle kernel NULL pointer dereference at 0000014c

[  656.966824] IP: [<c12b4320>] fbcon_blank+0x1a0/0x390

[  656.966824] *pde = 00000000

[  656.966824] Oops: 0000 [#2] PREEMPT SMP

[  656.966824] Modules linked in: huawei_cdc_ncm(F) cdc_ncm(F) mousedev snd_hda_codec_generic ppdev bochs_drm ttm snd_hda_intel
cfg80211 drm_kms_helper rfkill snd_hda_controller snd_hda_codec psmouse pcspkr serio_raw snd_hwdep drm snd_pcm option snd_timer
usb_wwan syscopyarea usbserial snd sysfillrect sysimgblt soundcore i2c_piix4 i6300esb i2c_core parport_pc parport acpi_cpufreq e
vdev processor mac_hid sch_fq_codel nfs lockd grace sunrpc fscache ext4 crc16 mbcache jbd2 dm_snapshot dm_bufio dm_mod squashfs
loop uas cdc_wdm isofs usbnet mii usb_storage sr_mod cdrom sd_mod ata_generic pata_acpi atkbd libps2 ata_piix uhci_hcd ehci_hcd
libata intel_agp intel_gtt usbcore e1000 scsi_mod usb_common agpgart floppy i8042 serio button [last unloaded: cdc_ncm]

[  656.966824] CPU: 0 PID: 1664 Comm: main Tainted: GF               4.0.4-2-ARCH #1

[  656.966824] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150617_082717-anatol 04/01/2014

[  656.966824] task: dd48c660 ti: d1722000 task.ti: d1722000

[  656.966824] EIP: 0060:[<c12b4320>] EFLAGS: 00210046 CPU: 0

[  656.966824] EIP is at fbcon_blank+0x1a0/0x390

[  656.966824] EAX: ddc34000 EBX: ced66800 ECX: 00000000 EDX: 00000000

[  656.966824] ESI: 00000000 EDI: 00000000 EBP: d172393c ESP: d1723864

[  656.966824]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068

[  656.966824] CR0: 80050033 CR2: 0000014c CR3: 11730000 CR4: 000007c0

[  656.966824] Stack:

[  656.966824]  00200002 00000025 c1720a40 00000000 00000000 00000000 ddc34000 c10a4915

[  656.966824]  c1720a40 c1582072 00000290 000ec0a8 00000290 00000000 00000000 c172d750

[  656.966824]  0000000f aa28c464 c164b5a0 c1320030 00200082 c162323c 00200082 d17238d0

[  656.966824] Call Trace:

[  656.966824]  [<c10a4915>] ? print_prefix+0xe5/0x170

[  656.966824]  [<c1320030>] ? serial8250_set_divisor.isra.7+0x80/0x80

[  656.966824]  [<c10a5c74>] ? wake_up_klogd+0x34/0x50

[  656.966824]  [<c10a5f9d>] ? console_unlock+0x30d/0x570

[  656.966824]  [<c10a44ad>] ? log_store+0x1cd/0x210

[  656.966824]  [<c10b5f40>] ? internal_add_timer+0x50/0x60

[  656.966824]  [<c10b6b89>] ? mod_timer+0xe9/0x1f0

[  656.966824]  [<c13152d6>] do_unblank_screen+0xb6/0x190

[  656.966824]  [<c13153bf>] unblank_screen+0xf/0x20

[  656.966824]  [<c125b3f8>] bust_spinlocks+0x18/0x40

[  656.966824]  [<c1005c5e>] oops_end+0x2e/0xc0

[  656.966824]  [<c1045ccb>] no_context+0x12b/0x250

[  656.966824]  [<c1045e95>] __bad_area_nosemaphore+0xa5/0x160

[  656.966824]  [<c10c5ced>] ? clockevents_program_event+0x8d/0x140

[  656.966824]  [<c1045f67>] bad_area_nosemaphore+0x17/0x20

[  656.966824]  [<c1046486>] __do_page_fault+0x2d6/0x500

[  656.966824]  [<c1046704>] trace_do_page_fault+0x34/0xe0

[  656.966824]  [<c1042880>] ? kvm_pv_reboot_notify+0x30/0x30

[  656.966824]  [<c1042898>] do_async_page_fault+0x18/0x70

[  656.966824]  [<c14a1a33>] error_code+0x67/0x6c

[  656.966824]  [<c13a00d8>] ? pcibios_lookup_irq+0x368/0x660

[  656.966824]  [<c12596f0>] ? memset+0x10/0x20

[  656.966824]  [<e0dff758>] cdc_ncm_fill_tx_frame+0x4c8/0x690 [cdc_ncm]

[  656.966824]  [<e0dff9d4>] cdc_ncm_tx_fixup+0x34/0x70 [cdc_ncm]

[  656.966824]  [<e0dff9a0>] ? cdc_ncm_bind+0x80/0x80 [cdc_ncm]

[  656.966824]  [<e08f3a50>] usbnet_start_xmit+0x60/0x7c0 [usbnet]

[  656.966824]  [<c13bce5b>] ? netif_skb_features+0xcb/0x440

[  656.966824]  [<c13ab87a>] ? __alloc_skb+0x6a/0x1e0

[  656.966824]  [<c13bd6b4>] dev_hard_start_xmit+0x224/0x3b0

[  656.966824]  [<c13bd1e5>] ? validate_xmit_skb.isra.33.part.34+0x15/0x2c0

[  656.966824]  [<c13da960>] sch_direct_xmit+0x100/0x1f0

[  656.966824]  [<c13bda12>] __dev_queue_xmit+0x1d2/0x500

[  656.966824]  [<c13d99b0>] ? ether_setup+0x80/0x80

[  656.966824]  [<c13bdd4f>] dev_queue_xmit+0xf/0x20

[  656.966824]  [<c13c744f>] neigh_resolve_output+0xff/0x200

[  656.966824]  [<c13f321a>] ip_finish_output+0x2ba/0x980

[  656.966824]  [<c13f5754>] ? __ip_make_skb+0x2a4/0x3b0

[  656.966824]  [<c13f4ec7>] ip_output+0x87/0xd0

[  656.966824]  [<c13f460c>] ? __ip_local_out+0x2c/0x80

[  656.966824]  [<c13f5a19>] ? ip_make_skb+0xd9/0x100

[  656.966824]  [<c13f4687>] ip_local_out_sk+0x27/0x30

[  656.966824]  [<c13f5874>] ip_send_skb+0x14/0x80

[  656.966824]  [<c141b0f1>] udp_send_skb+0x101/0x260

[  656.966824]  [<c141c656>] udp_sendmsg+0x2e6/0x900

[  656.966824]  [<c13f3a80>] ? ip_reply_glue_bits+0x80/0x80

[  656.966824]  [<c107f1c7>] ? update_cfs_rq_blocked_load+0x157/0x1a0

[  656.966824]  [<c1427525>] inet_sendmsg+0x75/0xa0

[  656.966824]  [<c13a213f>] do_sock_sendmsg+0x4f/0x80

[  656.966824]  [<c13a409f>] SyS_sendto+0x18f/0x1d0

[  656.966824]  [<c13a1feb>] ? sock_poll+0xeb/0x100

[  656.966824]  [<c11c5a40>] ? ep_read_events_proc+0xb0/0xb0

[  656.966824]  [<c11c5adf>] ? ep_send_events_proc+0x9f/0x1b0

[  656.966824]  [<c13a4c4c>] SyS_socketcall+0x19c/0x300

[  656.966824]  [<c14a0c97>] sysenter_do_call+0x12/0x12

[  656.966824] Code: 00 90 15 2b c1 0f 84 f0 00 00 00 31 c0 8b 7d f0 65 33 3d 14 00 00 00 0f 85 f1 01 00 00 81 c4 cc 00 00 00 5b
  5e 5f 5d c3 8d 76 00 <8b> 86 4c 01 00 00 85 c0 0f 84 20 ff ff ff a1 30 0a 72 c1 85 c0

[  656.966824] EIP: [<c12b4320>] fbcon_blank+0x1a0/0x390 SS:ESP 0068:d1723864

[  656.966824] CR2: 000000000000014c

[  656.966824] ---[ end trace f9032b6e1d2eba20 ]---

[  656.966824] Kernel panic - not syncing: Fatal exception in interrupt

[  656.966824] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0xc0000000-0xe07dffff)

[  656.966824] drm_kms_helper: panic occurred, switching back to text console

[  656.966824] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

qemu: terminating on signal 2
_mrkiko@gatosaldo:~\[mrkiko@gatosaldo ~]$ exit

Script done on Mon 06 Jul 2015 13:48:06 CEST

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
