From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: __netif_schedule on e1000e and 2.6.26-rc4
Date: Thu, 21 Aug 2008 11:36:06 -0400
Message-ID: <9e4733910808210836v6ec098daode36859ae52685ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:8536 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbYHUPgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:36:07 -0400
Received: by py-out-1112.google.com with SMTP id p76so29869pyb.10
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 08:36:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm hitting the __netif_schedule warning on 82566DC/e1000e with rc4.

This link hasn't gone up/down before in the past. It is a 24in cable
to the switch.

eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
eth0: Link is Down
eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
------------[ cut here ]------------
WARNING: at net/core/dev.c:1330 __netif_schedule+0x24/0x6a()
Modules linked in: nfsd exportfs container battery nfs lockd sunrpc
vfat fat nvidia(P) snd_hda_intel pl2303 ftdi_sio usbserial snd_pcm
snd_timer snd_page_alloc snd_hwdep e1000e i2c_core pcspkr evdev
intel_agp iTCO_wdt iTCO_vendor_support button snd sg sr_mod cdrom
sd_mod usbhid hid usb_storage ahci ehci_hcd uhci_hcd usbcore raid1
raid0 md_mod thermal processor fan
Pid: 15, comm: events/0 Tainted: P          2.6.26-jds #74

Call Trace:
 [<ffffffff8022cbd6>] warn_on_slowpath+0x51/0x78
 [<ffffffff8022d5b6>] printk+0x4e/0x56
 [<ffffffff8022474e>] __wake_up+0x38/0x4f
 [<ffffffff80234ea4>] lock_timer_base+0x26/0x4c
 [<ffffffff80235034>] __mod_timer+0xbd/0xcc
 [<ffffffff8038e9af>] __netif_schedule+0x24/0x6a
 [<ffffffffa00df6fa>] e1000_watchdog_task+0x473/0x68f [e1000e]
 [<ffffffffa00df287>] e1000_watchdog_task+0x0/0x68f [e1000e]
 [<ffffffff8023ad33>] run_workqueue+0x78/0x103
 [<ffffffff8023b60a>] worker_thread+0xd9/0xe8
 [<ffffffff8023de34>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8023b531>] worker_thread+0x0/0xe8
 [<ffffffff8023dd17>] kthread+0x47/0x74
 [<ffffffff802284e0>] schedule_tail+0x28/0x61
 [<ffffffff8020c029>] child_rip+0xa/0x11
 [<ffffffff8023dcd0>] kthread+0x0/0x74
 [<ffffffff8020c01f>] child_rip+0x0/0x11

---[ end trace 02864f428d58eac0 ]---


-- 
Jon Smirl
jonsmirl@gmail.com
