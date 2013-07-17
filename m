From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60564] New: LAN9115 device is dropping all RX packets
 using Linux kernel driver smsc911x
Date: Wed, 17 Jul 2013 08:22:56 -0700
Message-ID: <20130717082256.09d11af2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:49251 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531Ab3GQPXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 11:23:00 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so1936417pdi.30
        for <netdev@vger.kernel.org>; Wed, 17 Jul 2013 08:22:59 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id nm10sm8403758pbc.28.2013.07.17.08.22.58
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jul 2013 08:22:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 17 Jul 2013 03:09:36 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60564] New: LAN9115 device is dropping all RX packets using Linux kernel driver smsc911x


https://bugzilla.kernel.org/show_bug.cgi?id=60564

            Bug ID: 60564
           Summary: LAN9115 device is dropping all RX packets using Linux
                    kernel driver smsc911x
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4.52
          Hardware: ARM
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: jwoodward@tensor.co.uk
        Regression: No

LAN9115 device is dropping all RX packets using Linux kernel driver smsc911x.

eth0      Link encap:Ethernet  HWaddr 00:0D:A7:00:0E:5C
          inet addr:10.0.3.150  Bcast:10.0.3.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:18714 errors:0 dropped:16850 overruns:0 frame:0
          TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1380531 (1.3 MiB)  TX bytes:42 (42.0 B)
          Interrupt:194

CPU: ARM926EJ-S [41069264] revision 4 (ARMv5TEJ), cr=00053177

Linux version 3.4.52

**** mach-mx21ads config ******

static struct smsc911x_platform_config smsc911x_config = {
    .irq_polarity   = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
    .irq_type       = SMSC911X_IRQ_TYPE_PUSH_PULL,
    .flags          = SMSC911X_USE_16BIT,
};

static struct resource smsc911x_resources[] = {
    {
        .start          = MX21_CS1_BASE_ADDR,
        .end            = MX21_CS1_BASE_ADDR + MX21ADS_SMSC911X_MMIO_SIZE - 1,
        .flags          = IORESOURCE_MEM,
    }, {
        .start          = MX21ADS_SMSC911X_IRQ,
        .end            = MX21ADS_SMSC911X_IRQ,
        .flags          = IORESOURCE_IRQ | IRQF_TRIGGER_FALLING,
    },
};

static struct platform_device smsc911x_device = {
    .name           = "smsc911x",
    .id             = -1,
    .num_resources  = ARRAY_SIZE(smsc911x_resources),
    .resource       = smsc911x_resources,
    .dev            = {
        .platform_data = &smsc911x_config,
    },
};

*************************************************************

[    1.717445] 0x000001400000-0x000004000000 : "system"
[    1.745103] smsc911x: Driver version 2008-10-21
[    1.760910] smsc911x supply vdd33a not found, using dummy regulator
[    1.780099] smsc911x supply vddvario not found, using dummy regulator
[    1.799922] smsc911x smsc911x: (unregistered net_device): Driver Parameters:
[    1.821212] smsc911x smsc911x: (unregistered net_device): LAN base:
0xC8000000
[    1.842989] smsc911x smsc911x: (unregistered net_device): IRQ: 194
[    1.861629] smsc911x smsc911x: (unregistered net_device): PHY will be
autodetected.
[    1.884711] smsc911x smsc911x: (unregistered net_device): BYTE_TEST:
0x87654321
[    1.906753] smsc911x smsc911x: (unregistered net_device): LAN911x
identified, idrev: 0x01150002, generation: 2
[    1.939477] smsc911x smsc911x: eth0: Network interface: "eth0"
[    1.957323] smsc911x smsc911x: eth0: HW_CFG EXT_PHY_DET clear, using
internal PHY
[    1.982196] smsc911x-mdio: probed
[    1.992494] smsc911x smsc911x: eth0: PHY: addr 1, phy_id 0x0007C0D1
[    2.011538] smsc911x smsc911x: eth0: attached PHY driver [SMSC LAN911x
Internal PHY] (mii_bus:phy_addr=smsc911x-fffffff:01, irq=-1)
[    2.047536] smsc911x smsc911x: eth0: Successfully verified loopback packet
[    2.068587] smsc911x smsc911x: eth0: Passed Loop Back Test
[    2.085167] smsc911x smsc911x: eth0: phy initialised successfully
[    2.103647] smsc911x smsc911x: eth0: MAC Address is set to random_ether_addr
[    2.124918] smsc911x smsc911x: eth0: MAC Address: 9e:04:cb:db:dc:fe

~ # /apps/bin/networking
[   33.052642] smsc911x smsc911x: eth0: MAC Address: 00:0d:a7:00:0e:5c
[   33.077692] smsc911x smsc911x: eth0: irq polarity: active low
[   33.095092] smsc911x smsc911x: eth0: irq type: push-pull
[   33.111148] smsc911x smsc911x: eth0: Testing irq handler using IRQ 194
[   33.130867] smsc911x smsc911x: eth0: IRQ handler passed test using IRQ 194
[   33.151606] smsc911x smsc911x: eth0: SMSC911x/921x identified at 0xc8000000,
IRQ: 194
[   33.175253] smsc911x smsc911x: eth0: maccr 0x1000000C, HASHH 0x00000000,
HASHL 0x00000000
[   33.199962] smsc911x smsc911x: eth0: maccr 0x1000000C, HASHH 0x00000000,
HASHL 0x00000000
[   33.224807] smsc911x smsc911x: eth0: maccr 0x1000200C, HASHH 0x00000000,
HASHL 0x80000000

                CONFIGURING NETORK SETTINGS
10.0.3.150
 0.0.0.0
 255.255.255.0

[   33.343312] smsc911x smsc911x: eth0: maccr 0x1000200C, HASHH 0x00000000,
HASHL 0x80000000
[   33.373718] smsc911x smsc911x: eth0: Interface stopped
[   33.396198] smsc911x smsc911x: eth0: irq polarity: active low
[   33.413592] smsc911x smsc911x: eth0: irq type: push-pull
[   33.429650] smsc911x smsc911x: eth0: Testing irq handler using IRQ 194
[   33.449370] smsc911x smsc911x: eth0: IRQ handler passed test using IRQ 194
[   33.470110] smsc911x smsc911x: eth0: SMSC911x/921x identified at 0xc8000000,
IRQ: 194
[   33.493756] smsc911x smsc911x: eth0: maccr 0x1000000C, HASHH 0x00000000,
HASHL 0x00000000
[   33.518448] smsc911x smsc911x: eth0: maccr 0x1000000C, HASHH 0x00000000,
HASHL 0x00000000
[   33.543214] smsc911x smsc911x: eth0: maccr 0x1000200C, HASHH 0x00000000,
HASHL 0x80000000
[   33.569623] smsc911x smsc911x: eth0: maccr 0x1000200C, HASHH 0x00000000,
HASHL 0x80000000
route: SIOCADDRT: Invalid argument
~ #
~ # [   46.005715] smsc911x smsc911x: eth0: duplex state has changed
[   46.023086] smsc911x smsc911x: eth0: configuring for full duplex mode
[   46.042614] smsc911x smsc911x: eth0: rx pause disabled, tx pause disabled
[   46.063096] smsc911x smsc911x: eth0: carrier state has changed
[   46.080696] smsc911x smsc911x: eth0: configuring for no carrier
[   47.095737] smsc911x smsc911x: eth0: carrier state has changed
[   47.113360] smsc911x smsc911x: eth0: configuring for carrier OK

~ # ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: Symmetric Receive-only
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 1
        Transceiver: external
        Auto-negotiation: on
        Current message level: 0x0000ffff (65535)
                               drv probe link timer ifdown ifup rx_err tx_err
tx_queued intr tx_done rx_status pktdata hw wol 0x8000
        Link detected: yes

--
You are receiving this mail because:
You are the assignee for the bug.
