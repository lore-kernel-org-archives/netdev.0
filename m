From: Julia Niewiejska <julia.niewiejska@fkie.fraunhofer.de>
Subject: 802.3x pause frames
Date: Thu, 6 Nov 2014 13:59:53 +0100
Message-ID: <545B70C9.7090702@fkie.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:51533 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaKFNPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 08:15:50 -0500
Received: from rufsun5.fkie.fraunhofer.de ([128.7.2.5] helo=mailhost.fkie.fraunhofer.de)
	by a.mx.fkie.fraunhofer.de with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <julia.niewiejska@fkie.fraunhofer.de>)
	id 1XmMfJ-0000IQ-T8
	for netdev@vger.kernel.org; Thu, 06 Nov 2014 13:59:53 +0100
Received: from mailserv2acas.fkie.fraunhofer.de ([128.7.96.54] helo=mailserv2.fkie.fraunhofer.de)
	by mailhost.fkie.fraunhofer.de with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.72)
	(envelope-from <julia.niewiejska@fkie.fraunhofer.de>)
	id 1XmMfJ-0005SS-QU
	for netdev@vger.kernel.org; Thu, 06 Nov 2014 13:59:53 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I indend to do some experiments with 802.3x pause frames, but I have yet 
to find a setup that works. I used a tool that generates pause frames 
[1] in two setups. First one consists of two virtual machines on a 
VMWare ESXi 5.5 server connected with each other through a virtual 
switch. In second setup two physical machines (Desktop PCs) were 
connected directly by an ethernet cable. The VMs are running Debian 
Wheezy 32bit while Debian Testing (Jessie) 64bit is installed on both 
desktop PCs. Below you will find some information on the ethernet 
adapters and drivers used in the VM [2], the desktop PC with the more up 
to date hardware [3] and the older machine [4]. I used the following 
command to activate flow control:

ethtool -A <eth> autoneg off rx on tx on

First of all I noticed some discrepancies between the output of 
mii-tools or ethtool -a and the attempt to change the flow control 
settings with the command above. Only the Realtek adapter actually 
output that it didn't support the operation, the other adapters accepted 
the settings without any error message.

In both setups pause frames were generated on one machine while a ping 
was sent simultaneously, as suggested in [1]. While the VM connection 
was set to 1 Gbps the whole time, I also tested a 10 Mbps setting on the 
physical connection. Even though the pause frames were always visible in 
tcpdump at the receiver, I didn't notice any influence whatsoever in the 
ping results.

Did I miss some important settings that activate pause frame support, or 
is it possible that none of those different ethernet adapters and 
modules that were tested support at least the reception of pause frames? 
If so, are there any adapters that do support them? I'm also not sure 
how to interpret the output of ethtool. E.g. what does "Advertised pause 
frame use" mean, exactly?


Many thanks.

Julia Niewiejska


[1] http://www.tux.org/pub/sites/www.zip.com.au/%257Eakpm/linux/#flow-ctrl


----------------------------------------------
[2] Virtual machine on VMWare ESXi 5.5: Debian Wheezy 32bit, kernel 3.2

*** lspci -v ***

02:02.0 Ethernet controller: Intel Corporation 82545EM Gigabit Ethernet 
Controller (Copper) (rev 01)
         Subsystem: VMware PRO/1000 MT Single Port Adapter
         Physical Slot: 34
         Flags: bus master, 66MHz, medium devsel, latency 0, IRQ 16
         Memory at fd5a0000 (64-bit, non-prefetchable) [size=128K]
         Memory at fdfe0000 (64-bit, non-prefetchable) [size=64K]
         I/O ports at 2040 [size=64]
         [virtual] Expansion ROM at ebb10000 [disabled] [size=64K]
         Capabilities: [dc] Power Management version 2
         Capabilities: [e4] PCI-X non-bridge device
         Kernel driver in use: e1000


*** mii-tool -v ***

eth1: negotiated 1000baseT-FD flow-control, link ok
   product info: Yukon 88E1011 rev 3
   basic mode:   autonegotiation enabled
   basic status: autonegotiation complete, link ok
   capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD
   advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD 
10baseT-FD 10baseT-HD
   link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD



*** ethtool eth1 ***

Settings for eth1:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 0
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: Unknown
         Supports Wake-on: d
         Wake-on: d
         Current message level: 0x00000007 (7)
                                drv probe link
         Link detected: yes

*** ethtool -a eth1 ***

Pause parameters for eth1:
Autonegotiate:  on
RX:             off
TX:             off

----------------------------------------------
[3] Desktop PC 1: Debian Jessie 64bit, kernel 3.16

*** lspci -v ***

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 0c)
         Subsystem: ASUSTeK Computer Inc. Device 8554
         Flags: bus master, fast devsel, latency 0, IRQ 44
         I/O ports at d000 [size=256]
         Memory at f7100000 (64-bit, non-prefetchable) [size=4K]
         Memory at f2100000 (64-bit, prefetchable) [size=16K]
         Capabilities: [40] Power Management version 3
         Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
         Capabilities: [70] Express Endpoint, MSI 01
         Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
         Capabilities: [d0] Vital Product Data
         Capabilities: [100] Advanced Error Reporting
         Capabilities: [140] Virtual Channel
         Capabilities: [160] Device Serial Number 01-00-00-00-68-4c-e0-00
         Capabilities: [170] Latency Tolerance Reporting
         Kernel driver in use: r8169

*** mii-tool -v ***

eth0: negotiated 1000baseT-FD flow-control, link ok
   product info: vendor 00:07:32, model 0 rev 0
   basic mode:   autonegotiation enabled
   basic status: autonegotiation complete, link ok
   capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD
   advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD 
10baseT-FD 10baseT-HD flow-control
   link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD flow-control

*** ethtool eth0 ***

Settings for eth0:
         Supported ports: [ TP MII ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full 

         Supported pause frame use: No 

         Supports auto-negotiation: Yes 

         Advertised link modes:  10baseT/Half 10baseT/Full 

                                 100baseT/Half 100baseT/Full 

                                 1000baseT/Full 

         Advertised pause frame use: Symmetric Receive-only 

         Advertised auto-negotiation: Yes 

         Link partner advertised link modes:  10baseT/Half 10baseT/Full 

                                              100baseT/Half 
100baseT/Full
                                              1000baseT/Half 
1000baseT/Full
         Link partner advertised pause frame use: Symmetric Receive-only 

         Link partner advertised auto-negotiation: Yes 

         Speed: 1000Mb/s 

         Duplex: Full 

         Port: MII 

         PHYAD: 0 

         Transceiver: internal 

         Auto-negotiation: on 

         Supports Wake-on: pumbg 

         Wake-on: g 

         Current message level: 0x00000033 (51) 

                                drv probe ifdown ifup 

         Link detected: yes

*** ethtool -a eth0 ***

Pause parameters for eth0:
Cannot get device pause settings: Operation not supported


----------------------------------------------
[4] Desktop PC 2: Debian Jessie 64bit, kernel 3.16

*** lspci -v ***

00:19.0 Ethernet controller: Intel Corporation 82578DM Gigabit Network 
Connection (rev 05)
         Subsystem: Hewlett-Packard Company Device 304b 

         Flags: bus master, fast devsel, latency 0, IRQ 43 

         Memory at f0400000 (32-bit, non-prefetchable) [size=128K]
         Memory at f0425000 (32-bit, non-prefetchable) [size=4K]
         I/O ports at 2100 [size=32]
         Capabilities: [c8] Power Management version 2
         Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
         Capabilities: [e0] PCI Advanced Features
         Kernel driver in use: e1000e

*** mii-tool -v ***

eth1: negotiated 1000baseT-FD flow-control, link ok
   product info: vendor 00:13:74, model 4 rev 0
   basic mode:   autonegotiation enabled
   basic status: autonegotiation complete, link ok
   capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD
   advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD flow-control
   link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 
10baseT-HD flow-control

*** ethtool eth1 ***

Settings for eth1:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 2
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: off (auto)
         Supports Wake-on: pumbg
         Wake-on: g
         Current message level: 0x00000007 (7)
                                drv probe link
         Link detected: yes

*** ethtool -a eth1 ***

Pause parameters for eth1:
Autonegotiate:  on
RX:             on
TX:             off
