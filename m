From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Fri, 18 Apr 2008 18:18:29 +0300
Message-ID: <4808BBC5.5070800@teltonika.lt>
References: <20080414213238.GB28833@kroah.com> <200804161543.23584.oliver@neukum.org> <48060536.60005@teltonika.lt> <200804171632.12972.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804171632.12972.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Oliver Neukum wrote:
> 
> Hi,
> 
> can you test this one as well. The method used to determine whether
> a device is asleep is racy. This introduces a private test.
> 
> 	Regards
> 		Oliver

By setting level "auto" it didn't suspend...
When I tried to set "suspend" to the level I got crash:

hub 1-1.3:1.0: suspend error -16
Unable to handle kernel NULL pointer dereference at 000000000000004a RIP:
  [<ffffffff811ce082>] usb_kill_urb+0x28/0xf5
PGD 20c36067 PUD 2228e067 PMD 0
Oops: 0000 [1] SMP
CPU 0
Modules linked in: hso(U) rfkill i915 drm autofs4 fuse sunrpc loop 
dm_multipath ipv6 snd_hda_intel parport_pc pcspkr parport e100 
snd_seq_dummy r8169 mii i2c_i801 snd_seq_oss i2c_core snd_seq_midi_event 
snd_seq iTCO_wdt iTCO_vendor_support ftdi_sio snd_seq_device usbserial 
usblp snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc 
snd_hwdep snd soundcore button sr_mod sg cdrom dm_snapshot dm_zero 
dm_mirror dm_mod pata_acpi ata_generic ata_piix libata sd_mod scsi_mod 
ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd
Pid: 2920, comm: bash Not tainted 2.6.24.4-64.fc8debug #1
RIP: 0010:[<ffffffff811ce082>]  [<ffffffff811ce082>] usb_kill_urb+0x28/0xf5
RSP: 0018:ffff81001fd8dd88  EFLAGS: 00010202
RAX: 0000000000000000 RBX: 0000000000000002 RCX: ffffffff88323780
RDX: ffff81001fd8dfd8 RSI: 000000000000021e RDI: ffffffff813868d6
RBP: ffff810032c37b78 R08: 000000011fd88848 R09: 0000000000000000
R10: ffff81001fd8dd68 R11: 0000000000000028 R12: 0000000000000002
R13: ffff810037f38000 R14: 0000000000000002 R15: 0000000000000001
FS:  00002aaaaaac7f50(0000) GS:ffffffff81407000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000000004a CR3: 00000000124f4000 CR4: 00000000000006a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process bash (pid: 2920, threadinfo ffff81001fd8c000, task ffff81001fd88000)
Stack:  0000000000000246 ffff81003319d248 ffff81002d486e98 0000000000000246
  ffff81003319d250 ffff81003319d248 ffff81003319d250 ffff810032c37b68
  ffff810032c37b78 ffffffff8831ce54 0000000000000002 ffff81003d0f99b0
Call Trace:
  [<ffffffff8831ce54>] :hso:hso_stop_serial_device+0x4b/0x9b
  [<ffffffff8831cf13>] :hso:hso_suspend+0x26/0x67
  [<ffffffff811d0887>] usb_suspend_both+0xd7/0x27d
  [<ffffffff811d0a60>] usb_external_suspend_device+0x33/0x45
  [<ffffffff811d36b4>] set_level+0x125/0x189
  [<ffffffff810ee242>] sysfs_write_file+0xd7/0x115
  [<ffffffff810aa62f>] vfs_write+0xc6/0x16f
  [<ffffffff810aabec>] sys_write+0x45/0x6e
  [<ffffffff8100c053>] tracesys+0xd5/0xda


Code: 48 83 7b 48 00 0f 84 bb 00 00 00 48 83 7b 50 00 0f 84 b0 00
RIP  [<ffffffff811ce082>] usb_kill_urb+0x28/0xf5
  RSP <ffff81001fd8dd88>
CR2: 000000000000004a
---[ end trace e19a70acc4bb0aa4 ]---

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
