From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 15:43:31 +0300
Message-ID: <480C8BF3.5030908@teltonika.lt>
References: <20080417214719.GF17664@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080417214719.GF17664-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Here is the crash dump when I do "modprobe -r hso". I think I had no
problems when I was using not debug version of kernel.

hso: unloaded
usbcore: deregistering interface driver hso
general protection fault: 0000 [1] SMP
CPU 1
Modules linked in: i915 drm autofs4 fuse sunrpc loop dm_multipath ipv6 
parport_pc parport snd_hda_intel pcspkr i2c_i801 r8169 snd_seq_dummy 
e100 i2c_core mii iTCO_wdt snd_seq_oss hso(U) usblp snd_seq_midi_event 
iTCO_vendor_support rfkill snd_seq snd_seq_device snd_pcm_oss 
snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_hwdep snd soundcore 
button sg sr_mod cdrom dm_snapshot dm_zero dm_mirror dm_mod pata_acpi 
ata_generic ata_piix libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd 
ohci_hcd ehci_hcd
Pid: 2926, comm: modprobe Not tainted 2.6.24.4-64.fc8debug #1
RIP: 0010:[<ffffffff810559b6>]  [<ffffffff810559b6>] 
__lock_acquire+0xb6/0xce5
RSP: 0000:ffff810010497c88  EFLAGS: 00010046
RAX: 0000000000000002 RBX: 0000000000000046 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 6b6b6b6b6b6b6b80
RBP: 6b6b6b6b6b6b6b68 R08: 0000000000000002 R09: 0000000000000001
R10: ffffffff81046da4 R11: 0000000000000008 R12: ffff8100105b0000
R13: ffffffff88191780 R14: 00000000ffffffff R15: 6b6b6b6b6b6b6b80
FS:  00002aaaaaac76f0(0000) GS:ffff81003f0014b0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000008ca3f0 CR3: 000000001e917000 CR4: 00000000000006a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 2926, threadinfo ffff810010496000, task 
ffff8100105b0000)
Stack:  000000018149c2e8 0000000000000002 0000000000000000 ffffffff8149c2b8
  ffff81003d8a8920 0000000000000046 6b6b6b6b6b6b6b68 ffff81003d1a6890
  ffffffff88191780 00000000ffffffff 00000000ffffffff ffffffff81056a45
Call Trace:
  [<ffffffff81056a45>] lock_acquire+0x5a/0x73
  [<ffffffff81046da4>] __cancel_work_timer+0x51/0x1b5
  [<ffffffff812865c5>] _spin_lock_irq+0x2c/0x58
  [<ffffffff81046da4>] __cancel_work_timer+0x51/0x1b5
  [<ffffffff8105548e>] trace_hardirqs_on+0x12e/0x151
  [<ffffffff8818b317>] :hso:hso_serial_ref_free+0xc5/0xce
  [<ffffffff8105548e>] trace_hardirqs_on+0x12e/0x151
  [<ffffffff8818b252>] :hso:hso_serial_ref_free+0x0/0xce
  [<ffffffff81131c5d>] kref_put+0x6f/0x7a
  [<ffffffff8818b10b>] :hso:hso_disconnect+0x23/0x55
  [<ffffffff811d128b>] usb_unbind_interface+0x5c/0xb9
  [<ffffffff811b710d>] __device_release_driver+0x91/0xb3
  [<ffffffff811b7653>] driver_detach+0xd3/0x114
  [<ffffffff811b6be4>] bus_remove_driver+0x80/0xa3
  [<ffffffff811d0c1b>] usb_deregister+0x97/0xa4
  [<ffffffff8818d926>] :hso:hso_exit+0x2a/0x6a
  [<ffffffff8105ef9c>] sys_delete_module+0x18c/0x1bd
  [<ffffffff8100c053>] tracesys+0xd5/0xda


Code: 48 8b 6f 08 48 85 ed 0f 85 db 02 00 00 49 83 3f 00 75 03 4d
RIP  [<ffffffff810559b6>] __lock_acquire+0xb6/0xce5
  RSP <ffff810010497c88>
---[ end trace 8adbc80e43569c09 ]---
BUG: sleeping function called from invalid context at kernel/rwsem.c:21
in_atomic():0, irqs_disabled():1
INFO: lockdep is turned off.
irq event stamp: 5090
hardirqs last  enabled at (5089): [<ffffffff810a4773>] kfree+0xe1/0xec
hardirqs last disabled at (5090): [<ffffffff812865a8>] 
_spin_lock_irq+0xf/0x58
softirqs last  enabled at (4848): [<ffffffff8100d0cc>] 
call_softirq+0x1c/0x28
softirqs last disabled at (4835): [<ffffffff8100d0cc>] 
call_softirq+0x1c/0x28
Pid: 2926, comm: modprobe Tainted: G      D 2.6.24.4-64.fc8debug #1

Call Trace:
  [<ffffffff8102f4ca>] __might_sleep+0xd5/0xdd
  [<ffffffff81285256>] down_read+0x1e/0x6c
  [<ffffffff810653bb>] acct_collect+0x42/0x18f
  [<ffffffff8103ad47>] do_exit+0x21e/0x7de
  [<ffffffff8100d6e6>] kernel_math_error+0x0/0x71
  [<ffffffff812869ad>] error_exit+0x0/0xa9
  [<ffffffff81046da4>] __cancel_work_timer+0x51/0x1b5
  [<ffffffff810559b6>] __lock_acquire+0xb6/0xce5
  [<ffffffff81056a45>] lock_acquire+0x5a/0x73
  [<ffffffff81046da4>] __cancel_work_timer+0x51/0x1b5
  [<ffffffff812865c5>] _spin_lock_irq+0x2c/0x58
  [<ffffffff81046da4>] __cancel_work_timer+0x51/0x1b5
  [<ffffffff8105548e>] trace_hardirqs_on+0x12e/0x151
  [<ffffffff8818b317>] :hso:hso_serial_ref_free+0xc5/0xce
  [<ffffffff8105548e>] trace_hardirqs_on+0x12e/0x151
  [<ffffffff8818b252>] :hso:hso_serial_ref_free+0x0/0xce
  [<ffffffff81131c5d>] kref_put+0x6f/0x7a
  [<ffffffff8818b10b>] :hso:hso_disconnect+0x23/0x55
  [<ffffffff811d128b>] usb_unbind_interface+0x5c/0xb9
  [<ffffffff811b710d>] __device_release_driver+0x91/0xb3
  [<ffffffff811b7653>] driver_detach+0xd3/0x114
  [<ffffffff811b6be4>] bus_remove_driver+0x80/0xa3
  [<ffffffff811d0c1b>] usb_deregister+0x97/0xa4
  [<ffffffff8818d926>] :hso:hso_exit+0x2a/0x6a
  [<ffffffff8105ef9c>] sys_delete_module+0x18c/0x1bd
  [<ffffffff8100c053>] tracesys+0xd5/0xda

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
