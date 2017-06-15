From: crow <crow@linux.org.ba>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Thu, 15 Jun 2017 16:40:48 +0200
Message-ID: <CAG_g8w7hEdrwspMsNifZ+m82R_-V5=bxv5oMURWy9PRAZU+hHQ@mail.gmail.com>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
 <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com>
 <20170610152741.GB26740@lunn.ch> <CAG_g8w71SWc_X2U9pNWLVheO9Jf4ydPznAVp1x-Y9kwU3qhf1A@mail.gmail.com>
 <20170611152102.GA16021@lunn.ch> <CAG_g8w6iEiJ4V2M1=toWWqi1D7H2_p08ceWsbgZ1=PrEGQ2HkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org,
        "open list:ARM/Amlogic Meson..." <linux-amlogic@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:32822 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752535AbdFOOkx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:40:53 -0400
Received: by mail-io0-f169.google.com with SMTP id t87so13332143ioe.0
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 07:40:50 -0700 (PDT)
In-Reply-To: <CAG_g8w6iEiJ4V2M1=toWWqi1D7H2_p08ceWsbgZ1=PrEGQ2HkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Jun 11, 2017 at 7:03 PM, crow <crow@linux.org.ba> wrote:
> Hi Andrew,
>
> On Sun, Jun 11, 2017 at 5:21 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> Thank your for the suggestion, and thanks Martin to explaining me over
>>> IRC what actually I should do.
>>>
>>> I recompiled mainline kernel 4.12-rc4 with the Amlogic driver:
>>> replaced drivers/net/phy/meson-gxl.c with
>>> https://github.com/khadas/linux/blob/ubuntu-4.9/drivers/amlogic/ethernet/phy/amlogic.c
>>>
>>> But this did not solve the issue. As soon as i start git clone i lose
>>> network connection to device (no session timeout/disconnect this time,
>>> but I am unable to reconnect over SSH or to get OK ping replay back).
>>
>
> 1) First problem reported I can't reproduce anymore, every reboot/cold
> boot with mainline kernel the Ethernet speed is detected as
> "100Mbps/Full" , but as seen in first post there was this issue.

Once I did setup u-boot to have network in u-boot and did just an ping
to activate network. And after boot Ethernet was detected as 10Mbps.
But again was not able to reproduce it. I double check that I have 5E
cable.

in u-boot Ethernet is detected as below
kvim#ping x.x.x.x
Speed: 100, full duplex
Using dwmac.c9410000 device
host x.x.x.x is alive
kvim#

then I let ArchLinuxArm to boot and found out I can't connect to
device over SSH. Check over serial console and found:

# dmesg | tail -n 10
[    8.334790] meson8b-dwmac c9410000.ethernet eth0: device MAC
address 00:15:18:01:81:31
[    8.436668] Meson GXL Internal PHY 0.e40908ff:08: attached PHY
driver [Meson GXL Internal PHY] (mii_bus:phy_addr=0.e40908ff:08,
irq=-1)
[    8.535171] meson8b-dwmac c9410000.ethernet eth0: PTP not supported by HW
[   10.225264] brcmfmac: brcmf_c_preinit_dcmds: Firmware version =
wl0: Mar  1 2015 07:29:38 version 7.45.18 (r538002) FWID 01-6a2c8ad4
[   10.635703] meson8b-dwmac c9410000.ethernet eth0: Link is Up -
10Mbps/Half - flow control off
# uname -a
Linux khadasvimpro 4.12.0-rc4-3-ARCH #1 SMP Thu Jun 8 00:17:20 CEST
2017 aarch64 GNU/Linux
#
# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: no autonegotiation,, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 0001 0005 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0002 40e8 5400 1c1c 0000 0000 aaaa
    fff0 ffff 0000 000a 1407 0040 0000 105a
  product info: vendor 00:60:51, model 0 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
#
# ifconfig eth0 down && ifconfig eth0 up
[ 1972.596690] Meson GXL Internal PHY 0.e40908ff:08: attached PHY
driver [Meson GXL Internal PHY] (mii_bus:phy_addr=0.e40908ff:08,
irq=-1)
[ 1972.704156] meson8b-dwmac c9410000.ethernet eth0: PTP not supported by HW
[ 1974.795698] meson8b-dwmac c9410000.ethernet eth0: Link is Up -
100Mbps/Full - flow control off
#
# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000f 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0002 40e8 5400 1c1c 0000 0000 aaaa
    fff0 ffff 0000 020a 1407 00ca 0000 105a
  product info: vendor 00:60:51, model 0 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
#

2) see below
> 2) see below
>
>> So this shows it is more than a PHY problem. The Ethernet MAC driver
>> is probably also part of the problem.
>
> There are some stmmac fixes [1] in soon to be rc5, compiled current
> master (without amlogic.c) with the fixes but for me the issue still
> persist. I will compile once released rc5 with amlogic.c and report
> back.
>
>> Are there any mainline kernels which work O.K?
>
> Khadas VIM support was added in 4.12-rc1. And I did test all four rc's
> but without success.

I did test many Kernel builds but all test have failed when
downloading bigger files / doing git clone.
As Martin Blumenstingl suggested I start with first commit where
Khadas VIM support was added [0]. Then also Neil Armstrong suggested
[1]. Then all 4.12-rc1 - rc5.
Martin Blumenstingl have also found himself that: "I can reproduce the
Ethernet problem (tried downloading a 1GiB test file from leaseweb,
network got stuck after downloading ~70 MiB)". He suggested that I
should "play with the settings on your switch (disable jumbo frames,
etc.) to rule out the "exotic" stuff?". Well other device (x86_64)
connected on this same Switch port does not have any problem
downloading big files or doing git clone, as well as Khadas VIM with
Amlogic kernel. Also jumbo frames are not enabled, switch does have
only standard settings.

I also get questioned which qdisc I use:
And it seems I am already using fq_codel (ArchLinuxArm uses systemd):
$ tc -s -p qdisc
qdisc noqueue 0: dev lo root refcnt 2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth0 root
 Sent 7382956 bytes 60703 pkt (dropped 0, overlimits 0 requeues 18)
 backlog 0b 0p requeues 18
qdisc fq_codel 0: dev eth0 parent :1 limit 10240p flows 1024 quantum
1514 target 5.0ms interval 100.0ms memory_limit 32Mb ecn
 Sent 7382956 bytes 60703 pkt (dropped 0, overlimits 0 requeues 18)
 backlog 0b 0p requeues 18
  maxpacket 54 drop_overlimit 0 new_flow_count 14 ecn_mark 0
  new_flows_len 0 old_flows_len 0
$ pacman -Qi systemd
Name            : systemd
Version         : 232-8
Description     : system and service manager
Architecture    : aarch64
...
$


Regards,

>>     Andrew
>
> [1] https://github.com/torvalds/linux/commit/426849e6611f2092553f8d53372ae310818a6292

[0] https://github.com/torvalds/linux/commit/e15d2774b8c096f116bf7192b37e8652da71369e
[1] https://kernel.googlesource.com/pub/scm/linux/kernel/git/khilman/linux-amlogic/+/v4.12/integ
