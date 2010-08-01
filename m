From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: 2.6.35-rc6-git6: Reported regressions from 2.6.34
Date: Sun, 01 Aug 2010 14:39:20 -0500
Message-ID: <4C55CD68.1020401@lwfinger.net>
References: <2dWFdr9kTFM.A.P0D.spXVMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2dWFdr9kTFM.A.P0D.spXVMB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/01/2010 08:46 AM, Rafael J. Wysocki wrote:
> This message contains a list of some regressions from 2.6.34,
> for which there are no fixes in the mainline known to the tracking team.
> If any of them have been fixed already, please let us know.
> 
> If you know of any other unresolved regressions from 2.6.34, please let us
> know either and we'll add them to the list.  Also, please let us know
> if any of the entries below are invalid.
> 
> Each entry from the list will be sent additionally in an automatic reply
> to this message with CCs to the people involved in reporting and handling
> the issue.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16312
> Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
> Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date		: 2010-06-28 9:40 (35 days old)
> Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
> References	: http://marc.info/?l=linux-kernel&m=127771804806465&w=2
> Handled-By	: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
> Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27272

I am beginning to think that Bug 16312 is not the same as Bug 16122. Even with
the patches from 16312, I still get warnings as below:

[   11.728776] ------------[ cut here ]------------
[   11.728787] WARNING: at fs/fs-writeback.c:964 __mark_inode_dirty+0x10f/0x1a0()
[   11.728790] Hardware name: HP Pavilion dv2700 Notebook PC
[   11.728792] Modules linked in: loop(+) dm_mod ide_cd_mod cdrom
snd_hda_codec_conexant ide_pci_generic arc4 ecb b43 rng_core mac80211
snd_hda_intel r8712u(C) cfg80211 snd_hda_codec amd74xx snd_pcm sg ide_core
rfkill led_class snd_timer ssb mmc_core pcmcia snd joydev k8temp hwmon
i2c_nforce2 pcmcia_core forcedeth serio_raw snd_page_alloc i2c_core battery ac
button ext4 mbcache jbd2 crc16 ohci_hcd sd_mod ehci_hcd usbcore fan processor
ahci libahci libata scsi_mod thermal
[   11.728854] Pid: 2449, comm: udisks-part-id Tainted: G         C
2.6.35-rc6-realtek+ #15
[   11.728857] Call Trace:
[   11.728865]  [<ffffffff8104608a>] warn_slowpath_common+0x7a/0xb0
[   11.728869]  [<ffffffff810460d5>] warn_slowpath_null+0x15/0x20
[   11.728874]  [<ffffffff81129d5f>] __mark_inode_dirty+0x10f/0x1a0
[   11.728879]  [<ffffffff8111e07d>] touch_atime+0x12d/0x170
[   11.728885]  [<ffffffff810cab91>] generic_file_aio_read+0x5c1/0x720
[   11.728890]  [<ffffffff81107ca2>] do_sync_read+0xd2/0x110
[   11.728896]  [<ffffffff81077e7d>] ? trace_hardirqs_on+0xd/0x10
[   11.728900]  [<ffffffff811083c3>] vfs_read+0xb3/0x170
[   11.728906]  [<ffffffff81002d1c>] ? sysret_check+0x27/0x62
[   11.728909]  [<ffffffff811084cc>] sys_read+0x4c/0x80
[   11.728914]  [<ffffffff81002ceb>] system_call_fastpath+0x16/0x1b
[   11.728917] ---[ end trace 32e16cacad33229f ]---
[   11.728919] bdi-block not registered

The warnings do not occur with every boot and appear to be some kind of race
condition.

Larry
