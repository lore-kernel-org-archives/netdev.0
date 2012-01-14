From: Michael Mueller <malware@t-online.de>
Subject: de4x5 (was Re: [PATCH] Making de2104x working with BNC connection
 on 21040 chipset)
Date: Sat, 14 Jan 2012 10:51:59 +0100
Message-ID: <4F11503F.6000106@t-online.de>
References: <4F0F641B.5090407@t-online.de> <CAP=VYLpWbcBae11fcQPcuPmdfvir7N6F9QMdzXip=i4mMHjxsQ@mail.gmail.com> <4F10A287.2070008@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout05.t-online.de ([194.25.134.82]:53376 "EHLO
	mailout05.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2ANJwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 04:52:13 -0500
In-Reply-To: <4F10A287.2070008@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

I wrote [copy to you]:
> The original de4x5 does not exist in 3.0. The comments at the top of

My fault, it was not included into the compiled version of 3.1 for debian.

> When trying the de4x5 using 2.6.32 - which is what I can boot into
> without too much problems - it did lock the machine while starting the
> interface (ifconfig up). Sorry, but I do not feel like digging into this
> just now.

I did try this with 3.1 now and it did lock up too but started printing
out the cutting line of an oops. Replacing init by bash I got the
remainder of a trace on the console. I could catch it on a serial
console then:

# insmod ./de4x5.ko
[   47.051976] de4x5 0000:02:04.0: PCI INT A -> Link[LNKB] -> GSI 11
(level, low) -> IRQ 11
[   47.167825] 0000:02:04.0: DE434/5 at 0x9c00, h/w address
00:00:c0:e5:0c:c0
[   47.250320]       and requires IRQ11 (provided by PCI BIOS).
[   47.318094] de4x5.c:V0.546 2001/02/22 davies@maniac.ultranet.com
[   47.391488] de4x5 0000:02:05.0: PCI INT A -> Link[LNKC] -> GSI 11
(level, low) -> IRQ 11
[   47.507273] 0000:02:05.0: DE434/5 at 0x9800, h/w address
00:00:c0:3e:09:c0
[   47.589822]       and requires IRQ11 (provided by PCI BIOS).
[   47.657595] de4x5.c:V0.546 2001/02/22 davies@maniac.ultranet.com
# ifconfig eth2 up
[   52.750984] ------------[ cut here ]------------
[   52.806316] WARNING: at fs/proc/generic.c:323
__xlate_proc_name+0x88/0x92()
[   52.889717] Hardware name: K7S5A
[   52.956449] name 'DE434/5 (0000:02:05.0)'
[   53.004387] Modules linked in: de4x5 ext3 jbd mbcache dm_mod sr_mod
sd_mod cdrom crc_t10dif ata_generic ohci_hcd ehci_hcd pata_sis libata
scsi_mod epic100 usbcore sis900 mii floppy [last unloaded: de2104x]
[   53.225143] Pid: 162, comm: ifconfig Not tainted 3.1.0-1-686-pae #1
[   53.300113] Call Trace:
[   53.329345]  [<c1037684>] ? warn_slowpath_common+0x68/0x79
[   53.395051]  [<c1100231>] ? __xlate_proc_name+0x88/0x92
[   53.457545]  [<c10376fd>] ? warn_slowpath_fmt+0x29/0x2d
[   53.520037]  [<c1100231>] ? __xlate_proc_name+0x88/0x92
[   53.582530]  [<c1100285>] ? __proc_create+0x4a/0xe6
[   53.640866]  [<c1100486>] ? proc_mkdir_mode+0x18/0x3b
[   53.701285]  [<c1077e43>] ? register_handler_proc+0xbf/0xe5
[   53.768039]  [<c10769df>] ? __setup_irq+0x2c5/0x310
[   53.826385]  [<e0810af5>] ? de4x5_queue_pkt+0x290/0x290 [de4x5]
[   53.897288]  [<c1076ac5>] ? request_threaded_irq+0x9b/0xc2
[   53.962903]  [<e081311b>] ? de4x5_open+0x293/0x436 [de4x5]
[   54.028514]  [<c120e46b>] ? __dev_open+0x7a/0xa4
[   54.083728]  [<c120e631>] ? __dev_change_flags+0x8e/0x101
[   54.148298]  [<c120e703>] ? dev_change_flags+0x10/0x3b
[   54.209757]  [<c124e004>] ? devinet_ioctl+0x24d/0x502
[   54.270172]  [<c11ff049>] ? sock_ioctl+0x1b4/0x1db
[   54.327462]  [<c11fee95>] ? might_fault+0x5/0x5
[   54.381645]  [<c10d32fe>] ? do_vfs_ioctl+0x459/0x48f
[   54.441123]  [<c12b1037>] ? do_page_fault+0x2e0/0x2fc
[   54.501633]  [<c12b1024>] ? do_page_fault+0x2cd/0x2fc
[   54.562051]  [<c1078ca3>] ? __call_rcu+0xd6/0xe1
[   54.617262]  [<c10d3378>] ? sys_ioctl+0x44/0x68
[   54.671440]  [<c12b295f>] ? sysenter_do_call+0x12/0x28
[   54.732888] ---[ end trace 63fdd5a99a21a1c6 ]---

I changed the name from 'DE434/5' to 'DE434_5' since the slash seems to
be no good idea within a file/directory name. This does yield a lockup
with no message.


Michael
