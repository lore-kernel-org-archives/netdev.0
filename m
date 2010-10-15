From: sunitha ap <linketu@gmail.com>
Subject: Kernel crash when "requesting rt73.bin"
Date: Fri, 15 Oct 2010 09:35:33 -0700
Message-ID: <AANLkTikRdxp3PVeXtyhc=TL3r8Cx_mLBe3H4RYz7D2My@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40029 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab0JOQfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 12:35:33 -0400
Received: by pva18 with SMTP id 18so2414pva.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 09:35:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

   I am running linux on mini2440 (ARM based).

I am able to load most of the drivers and run fine.

When I load rt73usb.ko , I get a crash.

I have copied rt73.bin from my ubuntu 9.1 (x86) to /lib/firmware. Hope
that is OK
as it is a data file. If not, how do I compile it. I have tried commenting out
#CONFIG_STANDALONE
#CONFIG_PREVENT_FIRMWARE_BUILD
#CONFIG_FIRMWARE_IN_KERNEL

This creates .bin for many drivers but none for rt73.

The crash messages is below. I can provide any other info, if required

Thanks
linketu

rt73usb 1-1.1:1.0: firmware: requesting rt73.bin
Unable to handle kernel paging request at virtual address de17c157
pgd = c309c000
[de17c157] *pgd=00000000
Internal error: Oops: 3 [#1]
last sysfs file:
/sys/devices/platform/s3c2410-ohci/usb1/1-1/1-1.1/1-1.1:1.0/firmware/1-1.1:1.0/loading
Modules linked in: rt73usb rt2x00usb rt2x00lib mac80211 cfg80211
option usbserial rfcomm hidp l2cap crc16 bluetooth
CPU: 0    Not tainted  (2.6.32.11 #4)
PC is at put_page+0x4/0x144
LR is at skb_release_data+0x70/0xa8
pc : [<c0072f20>]    lr : [<c025945c>]    psr: 80000013
sp : c30ffed0  ip : 00000000  fp : 0014cbc8
r10: c39b9e40  r9 : c30fff04  r8 : c3814754
r7 : c38139ec  r6 : c38141e0  r5 : c39b9e40  r4 : 00000000
r3 : c38139ec  r2 : c38139ec  r1 : 000000ff  r0 : de17c157
Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: c000717f  Table: 3309c000  DAC: 00000015
Process Xfbdev (pid: 1425, stack limit = 0xc30fe270)
Stack: (0xc30ffed0 to 0xc3100000)
fec0:                                     00000000 c39b9e40 c38141e0 c025945c
fee0: c39b9e40 c3814754 c38141e0 c0258f78 00000000 bf094224 c03e0be0 0000001e
ff00: c03dd138 c39b9e40 00000000 c38141e0 00000000 00000000 00000000 c39b9e64
ff20: c334c540 00000002 00000000 00000010 00000000 00000000 c39b9e40 c38141e0
ff40: c38142c4 c38142b8 00000006 0000000a c0420a60 bf084d84 00000000 c30fe000
ff60: 00000018 00000001 00000006 c00456e0 00000100 c0045d28 0000002a c30fe000
ff80: 0000002a 00000000 04000000 0002f000 009ca433 c30fe000 be80d610 c002e068
ffa0: ffffffff f4000000 04000000 c002ec7c 0000009c 00000000 0000ca00 00000000
ffc0: 00150b78 00150b60 00030d00 0002f000 009ca433 0000004e be80d610 0014cbc8
ffe0: 80000000 be80d5b8 009c0000 000afc84 80000010 ffffffff 00000000 00000000
[<c0072f20>] (put_page+0x4/0x144) from [<c025945c>] (skb_release_data+0x70/0xa8)
[<c025945c>] (skb_release_data+0x70/0xa8) from [<c0258f78>]
(__kfree_skb+0xc/0xb0)
[<c0258f78>] (__kfree_skb+0xc/0xb0) from [<bf094224>]
(__ieee80211_rx_handle_packet+0x2e0/0x2ec [mac80211])
[<bf094224>] (__ieee80211_rx_handle_packet+0x2e0/0x2ec [mac80211])
from [<bf084d84>] (ieee80211_tasklet_handler+0x54)
[<bf084d84>] (ieee80211_tasklet_handler+0x54/0xe8 [mac80211]) from
[<c00456e0>] (tasklet_action+0x84/0xe0)
[<c00456e0>] (tasklet_action+0x84/0xe0) from [<c0045d28>]
(__do_softirq+0x78/0x104)
[<c0045d28>] (__do_softirq+0x78/0x104) from [<c002e068>] (asm_do_IRQ+0x68/0x80)
[<c002e068>] (asm_do_IRQ+0x68/0x80) from [<c002ec7c>] (__irq_usr+0x3c/0xc0)
Exception stack(0xc30fffb0 to 0xc30ffff8)
ffa0:                                     0000009c 00000000 0000ca00 00000000
ffc0: 00150b78 00150b60 00030d00 0002f000 009ca433 0000004e be80d610 0014cbc8
ffe0: 80000000 be80d5b8 009c0000 000afc84 80000010 ffffffff
Code: e59f0000 eaff74e9 c0072e40 e92d4070 (e5903000)
---[ end trace 912112f829d72a71 ]---
Kernel panic - not syncing: Fatal exception in interrupt
