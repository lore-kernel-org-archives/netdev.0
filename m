From: crow <crow@linux.org.ba>
Subject: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and stalled
 after some traffic
Date: Thu, 8 Jun 2017 19:30:12 +0200
Message-ID: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33682 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdFHRaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 13:30:15 -0400
Received: by mail-io0-f170.google.com with SMTP id t87so3427190ioe.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 10:30:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I have here two problems with Khadas VIM Pro device and Ethernet.

1) sometimes with the Kernel Linux 4.12-rc4 the Ethernet link is Up
but only 10Mbps.
Don't work (either SSH to device nor over serial console to ping out)
meson8b-dwmac c9410000.ethernet eth0: Link is Up - 10Mbps/Half - flow
control off

Works (if I do ifconfig eth0 down / up):
meson8b-dwmac c9410000.ethernet eth0: Link is Down
meson8b-dwmac c9410000.ethernet eth0: Link is Up - 100Mbps/Full - flow
control off

Whole log could be found in [0].

2) if downloading an amount of data while connected to device over
SSH, connection will stall and after some minutes SSH session would be
disconnected. Nothing is written in dmesg and ethtool shows me same
values before when Ethernet was working, and after when connection
stall. Whole log can be found in [1]

SSH to device (OK)
  -> Cloning linux git repo...
Cloning into bare repository '/opt/mmcblk1/linux-aarch64-git/linux'...
remote: Counting objects: 5399033, done.
remote: Compressing objects: 100% (1495/1495), done.
Receiving objects:   3% (161971/5399033), 73.20 MiB | 6.19 MiB/s

here the download stalled and SSH connection also stalled but not disconnected

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                             100baseT/Half 100baseT/Full
        Link partner advertised pause frame use: No
        Link partner advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 8
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: ug
        Wake-on: d
        Current message level: 0x0000003f (63)
                               drv probe link timer ifdown ifup
        Link detected: yes
#

after 2 min SSH connection disconnected

over serial console:
# ping -c3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
>From 10.8.8.6 icmp_seq=1 Destination Host Unreachable

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 0 received, +1 errors, 100% packet loss, time 2060ms
pipe 3
#

nothing in dmesg or in journalctl

also here is helps only to take port down and again up. restarting
networking services fails "timed out".

Regards,


[0] https://defuse.ca/b/jqXqW9Ip
[1] https://defuse.ca/b/bJLOAuX6
