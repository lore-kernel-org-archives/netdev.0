From: crow <crow@linux.org.ba>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Sat, 10 Jun 2017 09:29:45 +0200
Message-ID: <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35698 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbdFJH3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 03:29:47 -0400
Received: by mail-io0-f179.google.com with SMTP id k93so39902543ioi.2
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 00:29:47 -0700 (PDT)
In-Reply-To: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Jun 8, 2017 at 7:30 PM, crow <crow@linux.org.ba> wrote:
> Hi,
> I have here two problems with Khadas VIM Pro device and Ethernet.
>
> 1) sometimes with the Kernel Linux 4.12-rc4 the Ethernet link is Up
> but only 10Mbps.
> Don't work (either SSH to device nor over serial console to ping out)
> meson8b-dwmac c9410000.ethernet eth0: Link is Up - 10Mbps/Half - flow
> control off
>
> Works (if I do ifconfig eth0 down / up):
> meson8b-dwmac c9410000.ethernet eth0: Link is Down
> meson8b-dwmac c9410000.ethernet eth0: Link is Up - 100Mbps/Full - flow
> control off
>
> Whole log could be found in [0].
>
> 2) if downloading an amount of data while connected to device over
> SSH, connection will stall and after some minutes SSH session would be
> disconnected. Nothing is written in dmesg and ethtool shows me same
> values before when Ethernet was working, and after when connection
> stall. Whole log can be found in [1]
>
> SSH to device (OK)
>   -> Cloning linux git repo...
> Cloning into bare repository '/opt/mmcblk1/linux-aarch64-git/linux'...
> remote: Counting objects: 5399033, done.
> remote: Compressing objects: 100% (1495/1495), done.
> Receiving objects:   3% (161971/5399033), 73.20 MiB | 6.19 MiB/s
>
> here the download stalled and SSH connection also stalled but not disconnected
>
> # ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP MII ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>         Supported pause frame use: Symmetric Receive-only
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>         Advertised pause frame use: No
>         Advertised auto-negotiation: Yes
>         Link partner advertised link modes:  10baseT/Half 10baseT/Full
>                                              100baseT/Half 100baseT/Full
>         Link partner advertised pause frame use: No
>         Link partner advertised auto-negotiation: Yes
>         Speed: 100Mb/s
>         Duplex: Full
>         Port: MII
>         PHYAD: 8
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: ug
>         Wake-on: d
>         Current message level: 0x0000003f (63)
>                                drv probe link timer ifdown ifup
>         Link detected: yes
> #
>
> after 2 min SSH connection disconnected
>
> over serial console:
> # ping -c3 8.8.8.8
> PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
> From 10.8.8.6 icmp_seq=1 Destination Host Unreachable
>
> --- 8.8.8.8 ping statistics ---
> 3 packets transmitted, 0 received, +1 errors, 100% packet loss, time 2060ms
> pipe 3
> #
>
> nothing in dmesg or in journalctl
>
> also here is helps only to take port down and again up. restarting
> networking services fails "timed out".
>
> Regards,
>
>
> [0] https://defuse.ca/b/jqXqW9Ip
> [1] https://defuse.ca/b/bJLOAuX6


I am posting this only as Information if needed to others who may be
able to check this, as I am not able to do it:

I was told from Neil Armstrong to post PHY register dump information
from eth0, but to use official Khadas VIM Ubuntu image (Amlogic
kernel) and then mainline kernel 4.12-rc4 (which I am running on
ArchLinuxArm).

With custom Amlogic 4.9.26 kernel I was able to git clone linux repository:

Linux Khadas 4.9.26 #1 SMP PREEMPT Sun Jun 4 11:34:23 CST 2017 aarch64
aarch64 aarch64 GNU/Linux

# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000f 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0082 40e8 5400 0d80 1000 0000 a900
    fff0 ffff 0000 140a 1407 00ca 0000 105a
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

With custom Amlogic 3.1.14 kernel cloning linux repository was also working

Linux Khadas 3.14.29 #21 SMP PREEMPT Sat May 13 22:10:31 CST 2017
aarch64 aarch64 aarch64 GNU/Linux

# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000f 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 00c2 40e8 5400 0803 0000 0000 0009
    fff0 ffff 0000 020a 1407 00ca 0e00 105a
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

This now is register dump when SSH was working and before trying to
clone linux repository on mainline kernel. There is some differences
between mainline kernel and custom amlogic!

Linux khadasvimpro 4.12.0-rc4-3-ARCH #1 SMP Thu Jun 8 00:17:20 CEST
2017 aarch64 GNU/Linux

# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000d 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0002 40e8 5400 1c1c 0000 0000 aaaa
    fff0 ffff 0000 020a 1407 004a 0000 105a
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

This is register dump once when cloning stops and SSH session
disconnects, there is again some differences even between these two
mainline kernel register dumps (working and when it stops working)

Linux khadasvimpro 4.12.0-rc4-3-ARCH #1 SMP Thu Jun 8 00:17:20 CEST
2017 aarch64 GNU/Linux

# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000f 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0002 40e8 5400 1c1c 0000 0000 aaaa
    fff0 ffff 0000 040a 1407 004a 0000 105a
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

I was told to have a look at the Amlogic PHY driver and check if they
check or set these registers that differs. But as I really don't know
anything about development I am unable to understand this code or to
provide an fix.

These information which I found crucial I got from Martin Blumenstingl
regarding driver "debug" option:
There's no "debug" parameter for meson8b-dwmac because this is only a
few lines of code: [0]
What I should check is probably the PHY register dump (see above) or
debug output from stmmac  [1]. The meson8b-dwmac is just a "SoC
specific configuration + loader" for stmmac.

Also what Martin Blumenstingl wrote is following which is also crucial
for fixing the issue:
Amlogic has given their ethernet PHY driver some updates [2], it now
includes wake-on-lan, and they now have an internal_phy_read_status
which uses reset_internal_phy if there's a link and some error counter
exceeds some magic value.

Regards,

[0] https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
[1] http://elixir.free-electrons.com/linux/v4.8/source/Documentation/networking/stmmac.txt
[2] https://github.com/khadas/linux/blob/ubuntu-4.9/drivers/amlogic/ethernet/phy/amlogic.c#L129
