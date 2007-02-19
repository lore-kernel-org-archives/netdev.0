From: Alex Davis <alex14641@yahoo.com>
Subject: Kernel bug in bcm43xx-d80211
Date: Mon, 19 Feb 2007 13:48:20 -0800 (PST)
Message-ID: <358127.50930.qm@web50203.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50203.mail.yahoo.com ([206.190.38.44]:47997 "HELO
	web50203.mail.yahoo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932716AbXBSVzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 16:55:03 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I go the following Oops with the latest wireless-dev git when starting wpa_supplicant:

Feb 19 16:17:42 boss kernel: [  377.359573] BUG: unable to handle kernel NULL pointer dereference
at virtual address 00000002
Feb 19 16:17:42 boss kernel: [  377.359641]  printing eip:
Feb 19 16:17:42 boss kernel: [  377.359670] f8b2a3c3
Feb 19 16:17:42 boss kernel: [  377.359672] *pde = 00000000
Feb 19 16:17:42 boss kernel: [  377.359702] Oops: 0002 [#1]
Feb 19 16:17:42 boss kernel: [  377.359730] SMP
Feb 19 16:17:42 boss kernel: [  377.359799] Modules linked in: af_packet arc4 ecb blkcipher
rc80211_simple bcm43xx_d80211 80211 cfg80211 snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
snd_seq_device snd
_pcm_oss snd_mixer_oss ipv6 usbhid hid usbmouse snd_intel8x0 snd_ac97_codec b44 ssb ehci_hcd
uhci_hcd intel_agp yenta_socket pcmcia ac97_bus serio_raw usbcore agpgart rsrc_nonstatic ohci1394
snd_pcm ide_cd pc
mcia_core 8250_pci evdev firmware_class 8250 ieee1394 serial_core snd_timer cdrom snd crc32
soundcore snd_page_alloc unix
Feb 19 16:17:42 boss kernel: [  377.360945] CPU:    0
Feb 19 16:17:42 boss kernel: [  377.360946] EIP:    0060:[<f8b2a3c3>]    Not tainted VLI
Feb 19 16:17:42 boss kernel: [  377.360947] EFLAGS: 00010246   (2.6.20 #1)
Feb 19 16:17:42 boss kernel: [  377.361048] EIP is at do_mark_unused+0x0/0x7 [bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.361080] eax: f71d7000   ebx: 00000000   ecx: 00000000   edx:
00000000
Feb 19 16:17:42 boss kernel: [  377.361113] esi: 00000000   edi: f71d7000   ebp: f8b2a3c3   esp:
c192dee0
Feb 19 16:17:42 boss kernel: [  377.361146] ds: 007b   es: 007b   ss: 0068
Feb 19 16:17:42 boss kernel: [  377.361176] Process events/0 (pid: 6, ti=c192c000 task=c191ca70
task.ti=c192c000)
Feb 19 16:17:42 boss kernel: [  377.361210] Stack: f8b28629 00000000 c0103587 00000000 00000000
00000000 00000000 00000000
Feb 19 16:17:42 boss kernel: [  377.361433]        00000282 f8b2a3d8 f71d7000 f8b19db7 f71d7000
f8b19f50 f89b64a0 38058a67
Feb 19 16:17:42 boss kernel: [  377.361655]        f71d7000 f8b1a0dd 00000011 f71d7274 f71d7270
c18fd2c0 00000246 c012a392
Feb 19 16:17:42 boss kernel: [  377.361878] Call Trace:
Feb 19 16:17:42 boss kernel: [  377.361932]  [<f8b28629>] bcm43xx_call_for_each_loctl+0x30/0x9b
[bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.362003]  [<c0103587>] common_interrupt+0x23/0x28
Feb 19 16:17:42 boss kernel: [  377.362060]  [<f8b2a3d8>] bcm43xx_loctl_mark_all_unused+0xe/0x17
[bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.362129]  [<f8b19db7>] bcm43xx_periodic_every60sec+0x8/0x2e
[bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.362197]  [<f8b19f50>] do_periodic_work+0xb4/0xe9
[bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.362258]  [<f8b1a0dd>] bcm43xx_periodic_work_handler+0xb5/0x16f
[bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.362327]  [<c012a392>] run_workqueue+0x7e/0x14e
Feb 19 16:17:42 boss kernel: [  377.362381]  [<f8b1a028>] bcm43xx_periodic_work_handler+0x0/0x16f
[bcm43xx_d80211]
Feb 19 16:17:42 boss kernel: [  377.362449]  [<c012a5b0>] worker_thread+0x14e/0x16d
Feb 19 16:17:42 boss kernel: [  377.362503]  [<c011637f>] default_wake_function+0x0/0xc
Feb 19 16:17:42 boss kernel: [  377.362558]  [<c011637f>] default_wake_function+0x0/0xc
Feb 19 16:17:42 boss kernel: [  377.362613]  [<c012a462>] worker_thread+0x0/0x16d
Feb 19 16:17:42 boss kernel: [  377.362665]  [<c012d828>] kthread+0xa0/0xd1
Feb 19 16:17:42 boss kernel: [  377.362717]  [<c012d788>] kthread+0x0/0xd1
Feb 19 16:17:42 boss kernel: [  377.362769]  [<c01037c7>] kernel_thread_helper+0x7/0x10
Feb 19 16:17:42 boss kernel: [  377.362823]  =======================
Feb 19 16:17:42 boss kernel: [  377.362852] Code: 04 00 00 00 80 e3 01 0f 44 c1 88 44 24 02 8d 8a
72 03 00 00 89 f0 8d 54 24 02 e8 9f e1 ff ff 8b 5c 24 04 8b 74 24 08 83 c4 0c c3 <80> 62 02 fe 31
c0 c3 53 ba
c3 a3 b2 f8 8b 58 6c e8 21 e2 ff ff
Feb 19 16:17:42 boss kernel: [  377.364227] EIP: [<f8b2a3c3>] do_mark_unused+0x0/0x7
[bcm43xx_d80211] SS:ESP 0068:c192dee0

lspci -v 
02:03.0 Network controller: Broadcom Corporation BCM4309 802.11a/b/g (rev 03)
        Subsystem: Dell Truemobile 1450 MiniPCI
        Flags: bus master, fast devsel, latency 32, IRQ 18
        Memory at faff6000 (32-bit, non-prefetchable) [size=8K]

wpa_supplicant is version 0.4.9: I was trying to connect to a Linksys WRT54G using WEP encryption.

Relevant part of .config
CONFIG_BCM43XX=m
CONFIG_BCM43XX_DEBUG=y
CONFIG_BCM43XX_DMA=y
CONFIG_BCM43XX_PIO=y
CONFIG_BCM43XX_DMA_AND_PIO_MODE=y
# CONFIG_BCM43XX_DMA_MODE is not set
# CONFIG_BCM43XX_PIO_MODE is not set
# CONFIG_ZD1211RW is not set
CONFIG_BCM43XX_D80211=m
CONFIG_BCM43XX_D80211_PCI=y
CONFIG_BCM43XX_D80211_PCMCIA=y
CONFIG_BCM43XX_D80211_DEBUG=y
CONFIG_BCM43XX_D80211_DMA=y
CONFIG_BCM43XX_D80211_PIO=y
CONFIG_BCM43XX_D80211_DMA_AND_PIO_MODE=y
# CONFIG_BCM43XX_D80211_DMA_MODE is not set
# CONFIG_BCM43XX_D80211_PIO_MODE is not set
# CONFIG_RT2X00 is not set
# CONFIG_ADM8211 is not set
# CONFIG_P54_COMMON is not set
# CONFIG_ZD1211RW_D80211 is not set
CONFIG_NET_WIRELESS=y

Machine is a Dell Inspiron 9100 laptop with an HT-enabled Pentium 4. Kernel is configured with
SMP. Distro is Slackware 11.0.


I code, therefore I am



 
____________________________________________________________________________________
Need Mail bonding?
Go to the Yahoo! Mail Q&A for great tips from Yahoo! Answers users.
http://answers.yahoo.com/dir/?link=list&sid=396546091
