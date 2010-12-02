From: Jan Engelhardt <jengelh@medozas.de>
Subject: jme: UDP checksum error, and lots of them
Date: Thu, 2 Dec 2010 04:39:34 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:52725 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756606Ab0LBDjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 22:39:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2.6.36-rc8 (somewhat older, but the message is still there in recent 
kernels), for almost all UDP packets transmitted/receive, I get a kernel 
warning

Dec  2 04:30:52 localhost kernel: [  495.235252] jme 0000:02:00.5: eth0: 
UDP Checksum error.

Apparently this has something to do with the "vpnc" connector program
I am using, given tcpdump reports this too.
Other than that nothing seems wrong; the VPN connection works as
expected.

04:31:30.700682 IP (tos 0x0, ttl 64, id 1981, offset 0, flags [DF], proto UDP
(17), length 128)
    192.168.13.39.4500 > 134.76.22.1.4500: [bad udp cksum 9510!] UDP-encap:
 ESP(spi=0xf531cf9c,seq=0x6545), length 100
        0x0000:  4500 0080 07bd 4000 4011 c893 c0a8 0d27  E.....@.@......'
        0x0010:  864c 1601 1194 1194 006c 6a9a f531 cf9c  .L.......lj..1..
        0x0020:  0000 6545 6b65 ec1a 5cad 484d 96ae a596  ..eEke..\.HM....
        0x0030:  5db7 1e93 0c15 c4d4 510b 7206 e821 1d56  ].......Q.r..!.V
        0x0040:  c91b 1710 a8b9 6181 046a 210e 7804 c2fa  ......a..j!.x...
        0x0050:  6319 756c 1909 27be 4086 c1d2 01eb 241a  c.ul..'.@.....$.
        0x0060:  41c9 0548 dea7 2496 c633 abde a601 3253  A..H..$..3....2S
        0x0070:  7585 7b75 b587 c008 ee05 880a dc4b a3e7  u.{u.........K..
04:31:30.721666 IP (tos 0x0, ttl 62, id 28480, offset 0, flags [DF], proto UDP
 (17), length 1488)
    134.76.22.1.4500 > 192.168.13.39.4500: [no cksum] UDP-encap:
 ESP(spi=0x9d511170,seq=0x77eb), length 1460
        0x0000:  4500 05d0 6f40 4000 3e11 5dc0 864c 1601  E...o@@.>.]..L..
        0x0010:  c0a8 0d27 1194 1194 05bc 0000 9d51 1170  ...'.........Q.p

Why does the JME driver care so much about this that it needs to print 
this for every packet? It does not look like it has any offloading 
features.

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pg
        Wake-on: g
        Current message level: 0x000020c6 (8390)
        Link detected: yes

# lspci
02:00.5 Ethernet controller: JMicron Technology Corp. JMC260 PCI 
Express Fast Ethernet Controller (rev 02)
02:00.5 0200: 197b:0260 (rev 02)

