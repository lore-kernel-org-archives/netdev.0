From: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Subject: [OOPS] In __netif_receive_skb_core
Date: Thu, 7 Jan 2016 19:54:57 +0200
Message-ID: <568EA671.7000502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: noureddine@arista.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36926 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcAGRzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:55:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Trying to bring up the modem interface on Nokia n900 device with recent 
linux, leads to the following kernel oops (read from the mtdoops device):

<6>[  144.009765] bq27xxx-battery 2-0055: battery is not calibrated! 
ignoring capacity values
<5>[  145.88964] ssi-protocol ssi-protocol: WAKELINES TEST OK
<6>[  145.194793] IPv6: ADDRCONF(NETDEV_CHANGE): phonet0: link becomes ready
<1>[  145.358154] Unable to handle kernel NULL pointer dereference at 
virtual address 0000005c
<1>[  145.366821] pgd = ce530000
<1>[  145.369689] [0000005c] *pgd=8e44c831, *pte=00000000, *ppte=00000000
<0>[  145.376373] Internal error: Oops: 17 [#1] PREEMPT ARM
<4>[  145.381683] Modules linked in: cmt_speech nokia_modem ssi_protocol 
sha256_generic hmac drbg ansi_cprng ctr ccm rfcomm sd_mod scsi_mod 
bnep"bluetooth omaplfb pvrsrvkm ipv6 bq2415x_charger uinput hsi_char 
radio_platform_si4713 joydev omap_ssi_port video_bus_switch arc4 
wl1251_spi gpio_keys isp1704_charger wl1251 mac80211 smc91x mii cfg80211 
omap_wdt omap_sham crc7 tsc2005 tsc200x_core si4713 bq27xxx_battery 
leds_lp5523 leds_lp55xx_common adp1653 tsl2563 rtc_twl twl4030_wdt 
et8ek8 ad5820 v4l2_common smiaregs videodev twl4030_vibra ff_memless 
media lis3lv02d_i2c lis3lv02d input_polldev omap_ssi hsi ti_soc_thermal 
thermal_sys hwmon rx51_battery
<4>[  145.441802] CPU: 0 PID: 1040 Comm: csd Not tainted 4.4.0-rc7+ #2
<4>[  145.448120] Hardware name: Nokia RX-51 board
<4>[  145.452636] task: ce517700 ti: cef50000 task.ti: cef50000
<4>[  145.458343] PC is at __netif_receive_skb_core+0x7c0/0x92c
<4>[  145.464050] LR is at sock_queue_rcv_skb+0x208/0x214
<4>[  145.469207] pc : [<c0393ebc>]    lr : [<c03852f4>]    psr: 00 00113
<4>[  145.469207] sp : cef51e98  ip : 15800000  fp : c3a4a780
<4>[  145.481292] r10: c3a2005c  r9 : 00000000  r8 : c3987834
<4>[  145.486816] r7 : 0000f500  r6 : c3a20000  r5 : c3a20048  r4 : c3987780
<4>[  145.493682] r3 : 00000000  r2 : 00000002  r1 : 00000000  r0 : 00000000
<4>[  145.500579] Flags: nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM 
Segment none
<4>[  145.508087] Control: 10c5387d  Table: 8e530019  DAC: 00000051
<0>[  145.514160] Process csd (pid: 1040, stack limit = 0xcef50210)
<0>[  145.520202] Stack: (0xcef51e98 to 0xcef52000)
<0>[  145.524810] 1e80: 
       cf334000 cf3ccd90
<0>[  145.533447] 1ea0: 00000002 c3987780 c0651400 c3a5507c c3912000 
c0068534 c3a5507c 40000113
<0>[  145.542083] 1ec0: ffffffff bf3b5fac bf3b5d88 ffffffff 00000000 
c0675f80 c3987780 00000000
<0>[  145.550720] 1ee0: c0675f74 c0675f48 cef51f18 00000040 cef51f20 
c03965f4 c0396580 c0675f80
<0>[  145.559356] 1f00: 00000001 0000012c 00000040 c0676217 ffffc399 
c0396d48 cef51f18 cef51f18
<0>[  145.567993] 1f20: cef51f20 cef51f20 cf334000 00000008 c0677240 
00000008 c0677200 c067724c
<0>[  145.576629] 1f40: 00000100 00400100 c0440be4 c0030dec cf807f00 
fa2000cc 00000003 00000003
<0>[  145.585266] 1f60: ffffc398 00000004 10c53c7d 00000000 00000000 
cf802000 00000001 10c53c7d
<0>[  145.593902] 1f80: b6ea4f44 00001684 bee8e7dc c003119c 00000000 
c005b44c cef51fb0 b6e1b024
<0>[  145.602539] 1fa0: a0000010 ffffffff 10c5387d c043c610 b6ea71bc 
00000000 00000000 00002f48
<0>[  145.611175] 1fc0: 00000000 b6ea71bc 00002f48 b6ebb684 b6eba000 
b6ea4f44 00001684 bee8e7dc
<0>[  145.619812] 1fe0: 00019817 bee8e788 b6e19d0c b6e1b024 a0000010 
ffffffff 00000000 00000000
<4>[  145.628648] [<c0393ebc>] (__netif_receive_skb_core) from 
[<c03965f4>] (process_backlog+0x74/0xf4)
<4>[  145.637817] [<c03965f4>] (process_backlog) from [<c0396d48>] 
(net_rx_action+0xd0/0x284)
<4>[  145.646301] [<c0396d48>] (net_rx_action) from [<c0030dec>] 
(__do_softirq+0xb0/0x208)
<4>[  145.654479] [<c0030dec>] (__do_softirq) from [<c003119c>] 
(irq_exit+0x80/0xe4)
<4>[  145.662109] [<c003119c>] (irq_exit) from [<c005b44c>] 
(__handle_domain_irq+0x88/0xa8)
<4>[  145.670379] [<c005b44c>] (__handle_domain_irq) from [<c043c610>] 
(__irq_usr+0x50/0x80)
<0>[  145.678741] Code: e59d400c e5943014 e1530006 0a000025 (e593505c)
<4>[  145.685241] ---[ end trace 17f822c9893a7c21 ]---
<0>[  145.691864] Kernel pan)c - not syncing: Fatal exception in interrupt

I tracked the problem down to the commit 
<7866a621043fbaca3d7389e9b9f69dd1a2e5a855> ("dev: add per net_device 
packet type chains"). After reverting that commit, the oops no longer 
appear.

Userspace on Nokia N900 talks to the modem via phonet interface.

Please advice on how to proceed to fix the problem and if there is 
anything else I can provide.

Regards,
Ivo
