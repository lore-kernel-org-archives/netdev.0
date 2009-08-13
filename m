From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13975] New: BUG: unable to handle kernel
 paging request at 000d7a0b
Date: Thu, 13 Aug 2009 13:51:56 -0700
Message-ID: <20090813135156.07e020a5.akpm@linux-foundation.org>
References: <bug-13975-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: tonywhite100@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36533 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754940AbZHMUwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 16:52:22 -0400
In-Reply-To: <bug-13975-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 13 Aug 2009 14:02:01 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13975
> 
>            Summary: BUG: unable to handle kernel paging request at
>                     000d7a0b
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.30.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: tonywhite100@googlemail.com
>         Regression: Yes
> 

Interesting.

> Last kernel version tried was 2.6.30.1 and I did not experience this bug using
> that kernel.
> 
> The crash happens randomly at boot and requires an fsck to fix. The kernel
> locks up.
> 
> Here's the interesting part of the log :
> 
> Aug 13 07:54:02 pentium-three kernel: BUG: unable to handle kernel paging
> request at 000d7a0b
> Aug 13 07:54:02 pentium-three kernel: IP: [<c01596d4>] m_show+0x94/0x190
> Aug 13 07:54:02 pentium-three kernel: *pde = 00000000 
> Aug 13 07:54:02 pentium-three kernel: Oops: 0000 [#1] PREEMPT SMP 
> Aug 13 07:54:02 pentium-three kernel: last sysfs file:
> /sys/module/nf_conntrack_ftp/initstate
> Aug 13 07:54:02 pentium-three kernel: Modules linked in: fuse af_packet
> xt_tcpudp xt_limit nf_conntrack_ipv4 nf_defrag_ipv4 xt_state ipt_LOG ipt_REJECT
> nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables dm_crypt
> rt2500usb arc4 snd_cmipci ecb gameport snd_pcm_oss snd_mixer_oss snd_pcm
> snd_page_alloc snd_opl3_lib rt73usb snd_hwdep crc_itu_t snd_mpu401_uart
> snd_seq_dummy snd_seq_oss rt2x00usb snd_seq_midi rt2x00lib snd_rawmidi
> led_class input_polldev snd_seq_midi_event snd_seq mac80211 snd_timer
> snd_seq_device cfg80211 snd evdev parport_pc rtc_cmos soundcore pcspkr rtc_core
> parport i2c_piix4 rtc_lib i2c_core shpchp pci_hotplug ext4 mbcache jbd2 crc16
> dm_mirror dm_region_hash dm_log dm_snapshot dm_mod usbhid hid sg sr_mod cdrom
> sd_mod pata_acpi ata_generic ata_piix uhci_hcd libata 8139too ehci_hcd floppy
> 8139cp scsi_mod usbcore mii intel_agp
> Aug 13 07:54:02 pentium-three kernel:
> Aug 13 07:54:02 pentium-three kernel: Pid: 2489, comm: lsmod Not tainted
> (2.6.30-4.slh.2-sidux-686 #1) To   be   Filled
> Aug 13 07:54:02 pentium-three kernel: EIP: 0060:[<c01596d4>] EFLAGS: 00010246
> CPU: 0
> Aug 13 07:54:02 pentium-three kernel: EIP is at m_show+0x94/0x190
> Aug 13 07:54:02 pentium-three kernel: EAX: 00000000 EBX: 000d7a0b ECX: de10fef4
> EDX: 00000000
> Aug 13 07:54:02 pentium-three kernel: ESI: e100fc98 EDI: df169660 EBP: e100fb60
> ESP: de10fee8
> Aug 13 07:54:02 pentium-three kernel: DS: 007b ES: 007b FS: 00d8 GS: 0033 SS:
> 0068
> Aug 13 07:54:02 pentium-three kernel: Process lsmod (pid: 2489, ti=de10e000
> task=ddd0c840 task.ti=de10e000)
> Aug 13 07:54:02 pentium-three kernel: Stack:
> Aug 13 07:54:02 pentium-three kernel: df169660 c041097e e11ebc4c 0000e764
> e100fb64 c102a2e0 00010246 00000000
> Aug 13 07:54:02 pentium-three kernel: df169660 e100fb64 00000035 c01d3d56
> 00000200 00000000 000003fa b7f95006
> Aug 13 07:54:02 pentium-three kernel: df1aca80 df169688 00000006 00000061
> 0000002b 00000000 0000002a 00000000
> Aug 13 07:54:02 pentium-three kernel: Call Trace:
> Aug 13 07:54:02 pentium-three kernel: [<c01d3d56>] ? seq_read+0x206/0x3d0
> Aug 13 07:54:02 pentium-three kernel: [<c01d3b50>] ? seq_read+0x0/0x3d0
> Aug 13 07:54:02 pentium-three kernel: [<c01f84e4>] ? proc_reg_read+0x64/0xa0
> Aug 13 07:54:02 pentium-three kernel: [<c01f8480>] ? proc_reg_read+0x0/0xa0
> Aug 13 07:54:02 pentium-three kernel: [<c01bb59d>] ? vfs_read+0x9d/0x160
> Aug 13 07:54:02 pentium-three kernel: [<c01bb731>] ? sys_read+0x41/0x80
> Aug 13 07:54:02 pentium-three kernel: [<c010394c>] ? sysenter_do_call+0x12/0x28
> Aug 13 07:54:02 pentium-three kernel: Code: c6 34 01 00 00 39 f3 74 31 8d b6 00
> 00 00 00 8b 43 08 89 3c 24 c7 44 24 04 7e 09 41 c0 83 c0 0c 89 44 24 08 e8 ce
> a2 07 00 8b 1b <8b> 03 0f 18 00 90 39 f3 75 da b8 01 00 00 00 8b 8d d4 00 00 00 
> Aug 13 07:54:02 pentium-three kernel: EIP: [<c01596d4>] m_show+0x94/0x190
> SS:ESP 0068:de10fee8
> Aug 13 07:54:02 pentium-three kernel: CR2: 00000000000d7a0b
> Aug 13 07:54:02 pentium-three kernel: ---[ end trace 1e50990a393b4447 ]---
> 
> I'll attach lspci and if there is any other information required please just
> ask and I'll post it.
> 

We died running `lsmod'.

We died in kernel/module.c:m_show().

The last sysfs file which userspace accessed was
/sys/module/nf_conntrack_ftp/initstate.

>From which I surmise that nf_conntrack_ftp has somehow done something
bad to the module-related metadata which kernel/module.c presents to
userspace via /sys/module/nf_conntrack_ftp/initstate.  Or something like that.

Tell me: had you done any `rmmod's on that machine?  Perhaps of
netfilter modules?  If so, perhaps netfilter didn't properly clean up
after itself or something.

Oh.  "The crash happens randomly at boot".  That makes it hard.
