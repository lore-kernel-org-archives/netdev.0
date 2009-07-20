From: Luca Tettamanti <kronos.it@gmail.com>
Subject: kernel BUG at include/net/netns/generic.h:41!
Date: Mon, 20 Jul 2009 15:27:32 +0200
Message-ID: <20090720132732.GA14731@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:41006 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbZGTN1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 09:27:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
with recent git kernel (78af08d) I get the following BUG at startup (it seems
that racoon is triggering it):

[   20.371630] NET: Registered protocol family 15
[   20.371776] ------------[ cut here ]------------
[   20.371779] kernel BUG at /home/kronos/src/linux-2.6.git/include/net/netns/generic.h:41!
[   20.371781] invalid opcode: 0000 [#1] PREEMPT SMP 
[   20.371784] last sysfs file: /sys/module/microcode/initstate
[   20.371785] CPU 0 
[   20.371787] Modules linked in: af_key(+) ext3 jbd coretemp hwmon microcode loop snd_hda_codec_realtek arc4 snd_hda_intel ecb snd_hda_codec snd_hwdep iwlagn snd_pcm iwlcore snd_seq snd_timer mac80211 snd_seq_device video btusb snd bluetooth cfg80211 rtc_cmos rfkill pcspkr soundcore psmouse evdev rtc_core asus_laptop output rtc_lib snd_page_alloc battery button ac processor ext4 mbcache jbd2 crc16 dm_mod usbhid hid sg sr_mod cdrom sd_mod uhci_hcd sdhci_pci sdhci mmc_core led_class ata_piix ahci ohci1394 ieee1394 libata scsi_mod ehci_hcd usbcore intel_agp thermal fan unix
[   20.371822] Pid: 2896, comm: racoon Not tainted 2.6.31-rc3-00096-g78af08d-dirty #138 F3Sa                
[   20.371825] RIP: 0010:[<ffffffffa03bd404>]  [<ffffffffa03bd404>] pfkey_create+0x34/0x1ac [af_key]
[   20.371832] RSP: 0018:ffff88013d249eb8  EFLAGS: 00010246
[   20.371834] RAX: ffff88013d249fd8 RBX: 0000000000000000 RCX: ffff88013d249d18
[   20.371836] RDX: ffff88013f85a280 RSI: ffff88013f44ac00 RDI: 0000000000000001
[   20.371838] RBP: ffff88013d249ed8 R08: 0000000000000008 R09: ffff8800284017c0
[   20.371840] R10: ffff88013d249d30 R11: 000000000000000a R12: ffffffff814ec0a0
[   20.371842] R13: ffff88013f44ac00 R14: 0000000000000002 R15: ffffffffa03c00e0
[   20.371844] FS:  00007f90152f8710(0000) GS:ffff880028022000(0000) knlGS:0000000000000000
[   20.371847] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   20.371849] CR2: 00007f00ada76000 CR3: 000000013db06000 CR4: 00000000000006f0
[   20.371850] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   20.371853] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   20.371855] Process racoon (pid: 2896, threadinfo ffff88013d248000, task ffff88013e3a8000)
[   20.371856] Stack:
[   20.371858]  ffffffffa03c0100 000000000000000f 0000000000000001 ffff88013f44ac00
[   20.371860] <0> ffff88013d249f38 ffffffff811f1ffe ffff88013d249ef8 0000000081051ed7
[   20.371863] <0> ffff88013d249f60 0000000300000002 ffffffff814ec0a0 000000000178e400
[   20.371866] Call Trace:
[   20.371872]  [<ffffffff811f1ffe>] __sock_create+0x1b7/0x2b1
[   20.371875]  [<ffffffff811f2146>] sock_create+0x2d/0x2f
[   20.371878]  [<ffffffff811f2361>] sys_socket+0x29/0x5d
[   20.371883]  [<ffffffff8100bb2b>] system_call_fastpath+0x16/0x1b
[   20.371885] Code: 41 55 49 89 f5 41 54 49 89 fc 53 bf 01 00 00 00 8b 1d 3d 2f 00 00 e8 ed 45 eb e0 49 8b 94 24 38 07 00 00 85 db 74 04 3b 1a 76 04 <0f> 0b eb fe 48 63 c3 48 f7 d0 48 6b c0 f8 48 8b 5c 02 08 bf 01 
[   20.371904] RIP  [<ffffffffa03bd404>] pfkey_create+0x34/0x1ac [af_key]
[   20.371909]  RSP <ffff88013d249eb8>
[   20.371911] ---[ end trace 31464162cdbb79f4 ]---
[   20.371913] note: racoon[2896] exited with preempt_count 1

(the kernel is dirty because of changes to the asus_atk0110 hwmon driver).

I _think_ that the issue was introduced after -rc1, so if you want I can try to
bisect.

Luca
