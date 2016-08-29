From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Fwd: ixgbe: Can't get link / carrier on embedded NIC of a D-1518 CPU
Date: Mon, 29 Aug 2016 18:45:27 +0200
Message-ID: <CAF6-1L6upXsvSBH+7buUR=9nsK3spUByQm4r5+c=ByQqgzf4rg@mail.gmail.com>
References: <CAF6-1L75=7O7YZT2DN9YPcOpmaza+7kO=P+DMmvta3_eL4AbEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36980 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbcH2Qpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:45:30 -0400
Received: by mail-wm0-f43.google.com with SMTP id i5so101513065wmg.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 09:45:29 -0700 (PDT)
In-Reply-To: <CAF6-1L75=7O7YZT2DN9YPcOpmaza+7kO=P+DMmvta3_eL4AbEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


I'm having trouble getting a link up on a ixgbe card.

The hardware is a SuperMicro SYS-5018D-FN8T (
https://www.supermicro.nl/products/system/1U/5018/SYS-5018D-FN8T.cfm )
It includes a Intel=C2=AE Xeon=C2=AE processor D-1518 with embedded 10G Int=
el
NICs and cs4227 phys to SFP+ ports.

The optics in it is an official Intel optics FTLX8571D3BCVIT1  but I
tried with some direct attach cables and some active optical tables
and other optics as well with the same results.

I tried both latest stable 4.4.x and 4.8.0-rc4 kernels

There is no errors, just the device stays at NO-CARRIER. Even loading
the module with debug=3D16 doesn't show anything more.

Any idea what I can try ?


Cheers,

    Sylvain

--------

Debug output :

8: eth6: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state
DOWN mode DEFAULT group default qlen 1000
    link/ether 00:25:90:5d:f8:b2 brd ff:ff:ff:ff:ff:ff


bash# ethtool eth6
Settings for eth6:
    Supported ports: [ FIBRE ]
    Supported link modes:   1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: No
    Advertised link modes:  10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: No
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: FIBRE
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: off
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00007fff (32767)
                   drv probe link timer ifdown ifup rx_err tx_err
tx_queued intr tx_done rx_status pktdata hw wol
    Link detected: no

bash# ethtool -m eth6
    Identifier                                : 0x03 (SFP)
    Extended identifier                       : 0x04 (GBIC/SFP defined
by 2-wire interface ID)
    Connector                                 : 0x07 (LC)
    Transceiver codes                         : 0x10 0x00 0x00 0x01
0x00 0x00 0x00 0x00
    Transceiver type                          : 10G Ethernet: 10G Base-SR
    Transceiver type                          : Ethernet: 1000BASE-SX
    Encoding                                  : 0x06 (64B/66B)
    BR, Nominal                               : 10300MBd
    Rate identifier                           : 0x02 (8/4/2G Rx
Rate_Select only)
    Length (SMF,km)                           : 0km
    Length (SMF)                              : 0m
    Length (50um)                             : 80m
    Length (62.5um)                           : 30m
    Length (Copper)                           : 0m
    Length (OM3)                              : 300m
    Laser wavelength                          : 850nm
    Vendor name                               : Intel Corp
    Vendor OUI                                : 00:1b:21
    Vendor PN                                 : FTLX8571D3BCVIT1
    Vendor rev                                : A
    Optical diagnostics support               : Yes
    Laser bias current                        : 21.410 mA
    Laser output power                        : 0.6035 mW / -2.19 dBm
    Receiver signal average optical power     : 0.7226 mW / -1.41 dBm
    Module temperature                        : 41.82 degrees C /
107.27 degrees F
    Module voltage                            : 3.3114 V
    Alarm/warning flags implemented           : Yes
    Laser bias current high alarm             : Off
    Laser bias current low alarm              : Off
    Laser bias current high warning           : Off
    Laser bias current low warning            : Off
    Laser output power high alarm             : Off
    Laser output power low alarm              : Off
    Laser output power high warning           : Off
    Laser output power low warning            : Off
    Module temperature high alarm             : Off
    Module temperature low alarm              : Off
    Module temperature high warning           : Off
    Module temperature low warning            : Off
    Module voltage high alarm                 : Off
    Module voltage low alarm                  : Off
    Module voltage high warning               : Off
    Module voltage low warning                : Off
    Laser rx power high alarm                 : Off
    Laser rx power low alarm                  : Off
    Laser rx power high warning               : Off
    Laser rx power low warning                : Off
    Laser bias current high alarm threshold   : 13.200 mA
    Laser bias current low alarm threshold    : 2.000 mA
    Laser bias current high warning threshold : 12.600 mA
    Laser bias current low warning threshold  : 3.000 mA
    Laser output power high alarm threshold   : 1.0000 mW / 0.00 dBm
    Laser output power low alarm threshold    : 0.1585 mW / -8.00 dBm
    Laser output power high warning threshold : 0.7943 mW / -1.00 dBm
    Laser output power low warning threshold  : 0.1995 mW / -7.00 dBm
    Module temperature high alarm threshold   : 78.00 degrees C /
172.40 degrees F
    Module temperature low alarm threshold    : -13.00 degrees C /
8.60 degrees F
    Module temperature high warning threshold : 73.00 degrees C /
163.40 degrees F
    Module temperature low warning threshold  : -8.00 degrees C /
17.60 degrees F
    Module voltage high alarm threshold       : 3.7000 V
    Module voltage low alarm threshold        : 2.9000 V
    Module voltage high warning threshold     : 3.6000 V
    Module voltage low warning threshold      : 3.0000 V
    Laser rx power high alarm threshold       : 1.0000 mW / 0.00 dBm
    Laser rx power low alarm threshold        : 0.0100 mW / -20.00 dBm
    Laser rx power high warning threshold     : 0.7943 mW / -1.00 dBm
    Laser rx power low warning threshold      : 0.0158 mW / -18.01 dBm


bash# dmesg | grep ixgbe
[    2.837788] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
version 4.4.0-k
[    2.837885] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[    3.516335] ixgbe 0000:04:00.0: Multiqueue Enabled: Rx Queue count
=3D 8, Tx Queue count =3D 8
[    3.648453] ixgbe 0000:04:00.0: MAC: 5, PHY: 18, SFP+: 5, PBA No: 020A00=
-000
[    3.648532] ixgbe 0000:04:00.0: 00:25:90:5d:f8:b2
[    3.836240] ixgbe 0000:04:00.0: Intel(R) 10 Gigabit Network Connection
[    5.606778] ixgbe 0000:04:00.1: Multiqueue Enabled: Rx Queue count
=3D 8, Tx Queue count =3D 8
[    5.738691] ixgbe 0000:04:00.1: MAC: 5, PHY: 0, PBA No: 020A00-000
[    5.738779] ixgbe 0000:04:00.1: 00:25:90:5d:f8:b3
[    6.052155] ixgbe 0000:04:00.1: Intel(R) 10 Gigabit Network Connection
[   91.585568] ixgbe 0000:04:00.0: registered PHC device on eth6
[   91.700449] ixgbe 0000:04:00.0 eth6: detected SFP+: 5
