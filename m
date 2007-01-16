From: Pavel Roskin <proski@gnu.org>
Subject: Re: Can someone please try...
Date: Tue, 16 Jan 2007 13:29:02 -0500
Message-ID: <1168972142.8299.11.camel@dv>
References: <200701161806.02780.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:58356 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbXAPS3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 13:29:08 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1H6t2q-0007Qe-9v
	for netdev@vger.kernel.org; Tue, 16 Jan 2007 13:28:28 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701161806.02780.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-16 at 18:06 +0100, Michael Buesch wrote:
> ...the bcm43xx driver in my tree with a 4318 chip?

Things are progressing for me a bit because I observed an association to
an AP with no security.  I still had to use wpa_supplicant.

Unfortunately, there is a bigger issue with the new code.  When I
interrupt wpa_supplicant, the kernel reports several oopses and then
panics, so I have to reboot.  I had to use serial console just to
capture the messages.

I assume the first message is most relevant.  Here it is:

kernel BUG at /home/proski/src/linux-2.6/mm/slab.c:597!
invalid opcode: 0000 [1]
CPU 0
Modules linked in: bcm43xx_d80211 ssb
Pid: 2984, comm: wpa_supplicant Not tainted 2.6.20-rc3 #2
RIP: 0010:[<ffffffff8020aa5a>]  [<ffffffff8020aa5a>] kfree+0x5c/0x97
RSP: 0018:ffff81000727fd08  EFLAGS: 00010046
RAX: 0000000000000000 RBX: ffff81001e53a3c0 RCX: 0000000000000001
RDX: ffff810001689c40 RSI: 000000000727c010 RDI: ffff81001de38000
RBP: ffff81001de38000 R08: ffffffff8052c2e0 R09: ffff81001eac80c0
R10: ffff8100066153c0 R11: ffff8100066157c0 R12: 0000000000000286
R13: ffff810006dfb988 R14: ffff81001e23c000 R15: 0000000000000000
FS:  00002b75242c6cd0(0000) GS:ffffffff8056c000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000003a8ab12e60 CR3: 000000000727a000 CR4: 00000000000006e0
Process wpa_supplicant (pid: 2984, threadinfo ffff81000727e000, task ffff810011e3d0c0)
Stack:  ffff81001e53a3c0 0000000000000013 ffff81001dddc000 ffffffff802237be
 ffff81001eac80c0 ffffffff8801b2f6 ffffffff8056c980 ffffffff8028cb21
 ffff81000707c7b8 ffff81001e8921c0 ffff81001e892000 ffffffff8801b63a
Call Trace:
 [<ffffffff802237be>] kfree_skbmem+0x9/0x73
 [<ffffffff8801b2f6>] :bcm43xx_d80211:bcm43xx_destroy_dmaring+0x1d1/0x205
 [<ffffffff8028cb21>] free_irq+0xd8/0x120
 [<ffffffff8801b63a>] :bcm43xx_d80211:bcm43xx_dma_free+0x89/0xad
 [<ffffffff88008c7e>] :bcm43xx_d80211:bcm43xx_wireless_core_exit+0x29/0x76
 [<ffffffff88008dcc>] :bcm43xx_d80211:bcm43xx_remove_interface+0x101/0x135
 [<ffffffff804422d3>] ieee80211_stop+0xdd/0xf7
 [<ffffffff80407cac>] dev_close+0x52/0x71
 [<ffffffff8040750f>] dev_change_flags+0x5a/0x119
 [<ffffffff8042e57d>] devinet_ioctl+0x235/0x59b
 [<ffffffff804004a6>] sock_ioctl+0x1c8/0x1e5
 [<ffffffff80238f2a>] do_ioctl+0x1b/0x50
 [<ffffffff8022a82a>] vfs_ioctl+0x215/0x227
 [<ffffffff80242166>] sys_ioctl+0x3c/0x5c
 [<ffffffff80250ede>] system_call+0x7e/0x83


Code: 0f 0b eb fe 48 8b 7a 28 48 8b 1f 8b 13 3b 53 04 73 0c 89 d0
RIP  [<ffffffff8020aa5a>] kfree+0x5c/0x97
 RSP <ffff81000727fd08>

That's still the same Dell Latitude D520 with Core 2 Duo and Fedora Core
6, internal PCIe card 14e4:4312.  I'm using your current tree ending
with "bcm43xx-d80211: Various cleanups all over the code"

SMP is disabled this time, just to make things simpler.

-- 
Regards,
Pavel Roskin


