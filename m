From: Rabin Vincent <rabin@rab.in>
Subject: Re: br2684: convert to net_device_ops broke it
Date: Sat, 2 May 2009 19:16:06 +0530
Message-ID: <20090502134605.GA11168@debian>
References: <777914.38491.qm@web58405.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Mikko Vinni <mmvinni@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:10822 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787AbZEBNqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 09:46:24 -0400
Content-Disposition: inline
In-Reply-To: <777914.38491.qm@web58405.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2009 at 02:04:21AM -0700, Mikko Vinni wrote:
> my ADSL connection works well with kernel 2.6.29, but since commit
> 0ba25ff4c669e5395110ba6ab4958a97a9f96922 (br2684: convert to net_device_ops)
> entered the mainline using br2684ctl fails with the following bug:
> 
> kernel: [  321.015643] ATM dev 0: ADSL line: training
> kernel: [  323.011315] ATM dev 0: ADSL line: channel analysis
> kernel: [  327.019647] ATM dev 0: ADSL line: exchange
> kernel: [  328.013485] ATM dev 0: ADSL line: up (8000 kb/s down | 896 kb/s up)
> br2684ctl[5606]: Interface "nas0" could not be created, reason: File exists 
> br2684ctl[5606]: Communicating over ATM 0.0.33, encapsulation: LLC 
> kernel: [  334.414469] br2684_create: register_netdev failed
> kernel: [  334.421276] BUG: unable to handle kernel NULL pointer dereference at (null)
> kernel: [  334.421298] IP: [<c0201544>] strncmp+0x14/0x30
> kernel: [  334.421325] *pde = 00000000 
> kernel: [  334.421336] Oops: 0000 [#1] 
> kernel: [  334.421344] last sysfs file: /sys/module/br2684/initstate
> kernel: [  334.421355] Modules linked in: cxacru usbatm br2684 binfmt_misc ipv6 radeon drm bridge stp llc bnep sco rfcomm l2cap sbs sbshc powernow_k7 lp joydev ppdev pcmcia snd_ali5451 snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device i2c_ali15x3 i2c_ali1535 snd parport_pc parport psmouse i2c_core soundcore snd_page_alloc yenta_socket rsrc_nonstatic pcmcia_core serio_raw container video shpchp pci_hotplug ati_agp agpgart evdev ext4 mbcache jbd2 crc16 usbhid hid natsemi ide_cd_mod cdrom ohci1394 ide_gd_mod ieee1394 ohci_hcd usbcore fuse
> kernel: [  334.421493] 
> kernel: [  334.421505] Pid: 5606, comm: br2684ctl Not tainted (2.6.29-rc2-702-ge0463f5 #17) HP nx9005 (DG832A)       
> kernel: [  334.421518] EIP: 0060:[<c0201544>] EFLAGS: 00210016 CPU: 0
> kernel: [  334.421529] EIP is at strncmp+0x14/0x30
> kernel: [  334.421537] EAX: 00000000 EBX: dcc31b84 ECX: 0000000f EDX: d6658e78
> kernel: [  334.421547] ESI: 00000000 EDI: d6658e78 EBP: d6658e54 ESP: d6658e4c
> kernel: [  334.421556]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> kernel: [  334.421567] Process br2684ctl (pid: 5606, ti=d6658000 task=ccc48000 task.ti=d6658000)
> kernel: [  334.421575] Stack:
> kernel: [  334.421580]  d6658e78 400261f2 d6658eb8 de7e95dc d677c000 d677c000 00000000 d73acd80
> kernel: [  334.421600]  d6658eb0 00000002 00000002 3073616e b7fe3f00 0804ac80 08048ac0 00000000
> kernel: [  334.421619]  00000000 00000000 00000001 00000000 00000000 00000000 00000000 00000000
> kernel: [  334.421637] Call Trace:
> kernel: [  334.421646]  [<de7e95dc>] ? br2684_ioctl+0x20c/0x410 [br2684]
> kernel: [  334.421675]  [<c030b9f7>] ? vcc_ioctl+0xa7/0x380
> kernel: [  334.421701]  [<c0297af2>] ? sock_ioctl+0x52/0x240
> kernel: [  334.421723]  [<c0297aa0>] ? sock_ioctl+0x0/0x240
> kernel: [  334.421736]  [<c0193260>] ? vfs_ioctl+0x20/0x70
> kernel: [  334.421758]  [<c0193732>] ? do_vfs_ioctl+0x72/0x580
> kernel: [  334.421771]  [<c029a83c>] ? release_sock+0x7c/0x90
> kernel: [  334.421785]  [<c030a044>] ? pvc_setsockopt+0x44/0x60
> kernel: [  334.421798]  [<c029818f>] ? sys_setsockopt+0x5f/0xb0
> kernel: [  334.421812]  [<c0299cc1>] ? sys_socketcall+0x231/0x270
> kernel: [  334.421824]  [<c0193ca3>] ? sys_ioctl+0x63/0x70
> kernel: [  334.421837]  [<c01034c5>] ? sysenter_do_call+0x12/0x25
> kernel: [  334.421853] Code: 31 c0 eb 04 19 c0 0c 01 8b 34 24 8b 7c 24 04 c9 c3 8d b6 00 00 00 00 55 89 e5 83 ec 08 89 34 24 89 7c 24 04 89 c6 89 d7 49 78 08 <ac> ae 75 08 84 c0 75 f5 31 c0 eb 04 19 c0 0c 01 8b 34 24 8b 7c 
> kernel: [  334.421936] EIP: [<c0201544>] strncmp+0x14/0x30 SS:ESP 0068:d6658e4c
> kernel: [  334.421956] ---[ end trace c26391b26aac614a ]---
> /USR/SBIN/CRON[5723]: (root) CMD ([ -x /usr/sbin/update-motd ] && /usr/sbin/update-motd 2>/dev/null)
> kernel: [  557.287581] ACPI: EC: GPE storm detected, transactions will use polling mode
> 
> 
> I traced the failing strncmp call to be in the br2684_find_dev function. With the following patch
> the messages change a little bit, but the connection still doesn't work. It seems
> that net_dev->name is not initialized, but I have no idea where it should be set.
[..]
> I'll be glad to test any patches.

Please try the one below.

Rabin

>From 9f767672d3362bb07fb1d8764b0d26312eb2bb96 Mon Sep 17 00:00:00 2001
From: Rabin Vincent <rabin@rab.in>
Date: Sat, 2 May 2009 18:44:28 +0530
Subject: [PATCH] br2684: restore net_dev initialization

Commit 0ba25ff4c669e5395110ba6ab4958a97a9f96922 ("br2684: convert to
net_device_ops") inadvertently deleted the initialization of the net_dev
pointer in the br2684_dev structure, leading to crashes.  This patch
adds it back.

Reported-by: Mikko Vinni <mmvinni@yahoo.com>
Signed-off-by: Rabin Vincent <rabin@rab.in>
---
 net/atm/br2684.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 334fcd4..3100a89 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -549,6 +549,7 @@ static void br2684_setup(struct net_device *netdev)
 	struct br2684_dev *brdev = BRPRIV(netdev);
 
 	ether_setup(netdev);
+	brdev->net_dev = netdev;
 
 	netdev->netdev_ops = &br2684_netdev_ops;
 
-- 
1.6.2.4

