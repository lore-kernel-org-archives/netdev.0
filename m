From: Johannes Berg <johannes@sipsolutions.net>
Subject: crash with bcm43xx_dscape and multiple interfaces
Date: Fri, 11 Aug 2006 09:53:17 +0200
Message-ID: <44DC376D.6030408@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37348 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750752AbWHKHxa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 03:53:30 -0400
To: mbuesch@freenet.de, netdev <netdev@vger.kernel.org>,
	bcm43xx-dev@lists.berlios.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

I managed to crash it again :P

Here's approximately what I did:


johannes:/home/johannes# ifconfig wlan0 down

johannes:/home/johannes# cd /sys/class/ieee80211/phy0/

johannes:/sys/class/ieee80211/phy0# echo -n moni0 > add_iface

johannes:/sys/class/ieee80211/phy0# iwconfig wlan0 mode master

johannes:/sys/class/ieee80211/phy0# iwconfig wlan0 essid test

johannes:/sys/class/ieee80211/phy0# ifconfig moni0 down

johannes:/sys/class/ieee80211/phy0# iwconfig moni0 mode monitor

johannes:/sys/class/ieee80211/phy0# ifconfig wlan0 up

johannes:/sys/class/ieee80211/phy0# ifconfig moni0 up

Segmentation fault

bcm43xx_d80211: ASSERTION FAILED (bcm->cached_beacon) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:1754:bcm43xx_update_templates()

bcm43xx_d80211: ASSERTION FAILED (bcm->cached_beacon) at: drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:1603:bcm43xx_write_beacon_template()

Unable to handle kernel paging request for data at address 0x00000060

Faulting instruction address: 0xf24cf308

Oops: Kernel access of bad area, sig: 11 [#1]

Aug 10 20:55:18 johannes kernel: [ 1095.326784]

Modules linked in: af_packet radeon drm binfmt_misc hci_usb rfcomm l2cap bluetooth nls_utf8 hfsplus nls_base joydev appletouch usbhid snd_aoa_codec_tas snd_aoa_fabric_layout snd_aoa arc4 rate_control evdev bcm43xx_d80211 firmware_class snd_aoa_i2sbus snd_pcm snd_timer snd_page_alloc snd uninorth_agp ohci1394 ieee1394 agpgart soundcore snd_aoa_soundbus yenta_socket rsrc_nonstatic pcmcia_core ohci_hcd ehci_hcd usbcore 80211 unix

NIP: F24CF308 LR: F24CF348 CTR: C01BACA4

REGS: c1e83c70 TRAP: 0300   Not tainted  (2.6.18-rc4)

MSR: 00001032 <ME,IR,DR>  CR: 24008422  XER: 00000000

DAR: 00000060, DSISR: 40000000

TASK = e8b88070[3419] 'ifconfig' THREAD: c1e82000

GPR00: F24CF348 C1E83D20 E8B88070 000000A4 0000A2E8 FFFFFFFF C0560000 00200000

GPR08: 00000033 00000000 00200000 C0510000 44008488 10018A14 28004422 00000000

GPR16: 1023D638 100D0000 100B0000 100D0000 10010474 E5A48000 C1E83E58 FFFF8914

GPR24: E5A48280 EFEC2400 00000004 00000000 00000068 00000002 00000018 EFEC2400

NIP [F24CF308] bcm43xx_write_beacon_template+0x50/0x98 [bcm43xx_d80211]

LR [F24CF348] bcm43xx_write_beacon_template+0x90/0x98 [bcm43xx_d80211]

Call Trace:

[C1E83D20] [F24CF348] bcm43xx_write_beacon_template+0x90/0x98 [bcm43xx_d80211] (unreliable)

[C1E83D40] [F24CFE44] bcm43xx_refresh_templates+0x48/0x268 [bcm43xx_d80211]

[C1E83D70] [F24D24AC] bcm43xx_add_interface+0xe4/0x118 [bcm43xx_d80211]

[C1E83DA0] [F20BDFD4] ieee80211_open+0x120/0x398 [80211]

[C1E83DF0] [C021E8C8] dev_open+0x78/0xcc

[C1E83E10] [C021C7E0] dev_change_flags+0x13c/0x168

[C1E83E30] [C0261C80] devinet_ioctl+0x5bc/0x71c

[C1E83EA0] [C02623F8] inet_ioctl+0xb0/0xdc

[C1E83EB0] [C0210810] sock_ioctl+0x160/0x28c

[C1E83ED0] [C0096604] do_ioctl+0x38/0x84

[C1E83EE0] [C00966D4] vfs_ioctl+0x84/0x43c

[C1E83F10] [C0096ACC] sys_ioctl+0x40/0x74

[C1E83F40] [C0010C88] ret_from_syscall+0x0/0x38

--- Exception: c01 at 0xff62780

    LR = 0xffecf54

Instruction dump:

3c80f24f 7cbe2b78 3ca0f24f 7cdd3378 3884c650 38a5c3f8 812304f8 3c60f24f

38c00643 3863c3b8 2f890000 419e0040 <80a90060> 7fe3fb78 7f86e378 7fc7f378

