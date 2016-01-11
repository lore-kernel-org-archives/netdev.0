From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [OOPS] In __netif_receive_skb_core
Date: Mon, 11 Jan 2016 14:11:52 -0800
Message-ID: <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
References: <568EA671.7000502@gmail.com>
	<56929985.3020502@gmail.com>
	<1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<5694188F.80907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5694188F.80907@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Would you be able to disassemble your kernel so we could tell where
the null pointer dereference happens?

Thanks,

Salam

On Mon, Jan 11, 2016 at 1:03 PM, Ivaylo Dimitrov
<ivo.g.dimitrov.75@gmail.com> wrote:
>
>
> On 10.01.2016 22:26, Eric Dumazet wrote:
>>
>>
>> I do not see anything wrong with this commit.
>>
>> It must uncover a prior bug.
>>
>
> Could be, but it was working fine in 3.19.
>
>> Seems to be a phonet bug not reacting to NETDEV_DOWN maybe ?
>>
>>
>> diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
>> index a58680016472..fd2f44940bd7 100644
>> --- a/net/phonet/pn_dev.c
>> +++ b/net/phonet/pn_dev.c
>
>
> The patch makes difference:
>
> <3>[  118.943542] et8ek8 3-003e: could not get clock
> <6>[  119.028045] IPv6: ADDRCONF(NETDEV_UP): phonet0: link is not ready
> <4>[  120.945922] sched: RT throttling activated
> <5>[  158.556091] ssi-protocol ssi-protocol: WAKELINES TEST OK
> <6>[  158.561828] IPv6: ADDRCONF(NETDEV_CHANGE): phonet0: link becomes ready
> <1>[  158.708831] Unable to handle kernel NULL pointer dereference at
> virtual address 0000005c
> <1>[  158.717498] pgd = ce548000
> <1>[  158.720367] [0000005c] *pgd=8e53a831, *pte=00000000, *ppte=00000000
> <0>[  158.727020] Internal error: Oops: 17 [#1] PREEMPT ARM
> <4>[  158.732330] Modules linked in: cmt_speech nokia_modem ssi_protocol
> vfat fat rfcomm sd_mod scsi_mod bnep bluetooth omaplfb pvrsrvkm ipv6
> bq2415x_charger uinput hsi_char radio_platform_si4713 joydev omap_ssi_port
> video_bus_switch arc4 wl1251_spi wl1251 isp1704_charger gpio_keys mac80211
> smc91x mii cfg80211 omap_wdt omap_sham crc7 tsc2005 tsc200x_core si4713
> leds_lp5523 leds_lp55xx_common adp1653 bq27xxx_battery tsl2563 twl4030_wdt
> rtc_twl et8ek8 smiaregs ad5820 v4l2_common twl4030_vibra ff_memless videodev
> lis3lv02d_i2c media lis3lv02d input_polldev omap_ssi hsi ti_soc_thermal
> thermal_sys hwmon rx51_battery
> <4>[  158.789154] CPU: 0 PID: 1038 Comm: csd Not tainted 4.4.0-rc7+ #14
> <4>[  158.795562] Hardware name: Nokia RX-51 board
> <4>[  158.800048] task: ce4d5900 ti: ce4e4000 task.ti: ce4e4000
> <4>[  158.805725] PC is at __netif_receive_skb_core+0x7c0/0x92c
> <4>[  158.811401] LR is at sock_queue_rcv_skb+0x208/0x214
> <4>[  158.816528] pc : [<c0394218>]    lr : [<c0385648>]    psr: 00000113
> <4>[  158.816528] sp : ce4e5e98  ip : 14400000  fp : cd4ab380
> <4>[  158.828582] r10: c249405c  r9 : 00000000  r8 : c24b2d74
> <4>[  158.834045] r7 : 0000f500  r6 : c2494000  r5 : c2494048  r4 : c24b2cc0
> <4>[  158.840911] r3 : 00000000  r2 : 00000002  r1 : 00000000  r0 : 00000000
> <4>[  158.847778] Flags: nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
> Segment none
> <4>[  158.855285] Control: 10c5387d  Table: 8e548019  DAC: 00000051
> <0>[  158.861297] Process csd (pid: 1038, stack limit = 0xce4e4210)
> <0>[  158.867340] Stack: (0xce4e5e98 to 0xce4e6000)
> <0>[  158.871917] 5e80:       cf3ab000 cf2e4d90
> <0>[  158.880554] 5ea0: 00000002 c24b2cc0 c06534dc c243b67c c5dcae00
> c00685ac c243b67c 40000113
> <0>[  158.889129] 5ec0: ffffffff bf3b0fac bf3b0d88 ffffffff 00000000
> c06780c0 c24b2cc0 00000000
> <0>[  158.897735] 5ee0: c06780b4 c0678088 ce4e5f18 00000040 ce4e5f20
> c0396950 c03968dc c06780c0
> <0>[  158.906341] 5f00: 00000001 0000012c 00000040 c0678357 ffffc8d0
> c03970a4 ce4e5f18 ce4e5f18
> <0>[  158.914947] 5f20: ce4e5f20 ce4e5f20 cf3ab000 00000008 c0679380
> 00000008 c0679340 c067938c
> <0>[  158.923522] 5f40: 00000100 00400100 c0441be8 c0030e64 cf807f00
> fa2000cc 00000003 00000003
> <0>[  158.932128] 5f60: ffffc8cf 00000004 10c53c7d 00000000 00000000
> cf802000 00000001 10c53c7d
> <0>[  158.940734] 5f80: 00001a30 0000026c beba476c c0031214 00000000
> c005b4c4 ce4e5fb0 b6e3f82c
> <0>[  158.949310] 5fa0: 40000010 ffffffff 10c5387d c043c990 00000014
> 00000000 0001ef78 00000014
> <0>[  158.957946] 5fc0: 0001edf8 00000001 00000000 00000000 00000000
> 00001a30 0000026c beba476c
> <0>[  158.966522] 5fe0: b6e4d82c beba4748 b6e3f82c b6e3f82c 40000010
> ffffffff ddee3fd6 e7f5d5dd
> <4>[  158.975158] [<c0394218>] (__netif_receive_skb_core) from [<c0396950>]
> (process_backlog+0x74/0xf4)
> <4>[  158.984497] [<c0396950>] (process_backlog) from [<c03970a4>]
> (net_rx_action+0xd0/0x284)
> <4>[  158.992919] [<c03970a4>] (net_rx_action) from [<c0030e64>]
> (__do_softirq+0xb0/0x208)
> <4>[  159.001037] [<c0030e64>] (__do_softirq) from [<c0031214>]
> (irq_exit+0x80/0xe4)
> <4>[  159.008636] [<c0031214>] (irq_exit) from [<c005b4c4>]
> (__handle_domain_irq+0x88/0xa8)
> <4>[  159.016906] [<c005b4c4>] (__handle_domain_irq) from [<c043c990>]
> (__irq_usr+0x50/0x80)
> <0>[  159.025207] Code: e59d400c e5943014 e1530006 0a000025 (e593505c)
> <4>[  159.031677] ---[ end trace c52d1e36f2d07d67 ]---
> <0>[  159.038146] Kernel panic - not syncing: Fatal exception in interrupt
> --[ end trace c52d1e36f2d07d67 ]---
>
> Could you provide some hints on where to put some printks or dump some data
> to get a clearer picture on what happens?
>
> Thanks,
> Ivo
