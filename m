From: Corentin CHARY <corentincj@iksaif.net>
Subject: Re: r8168, 2.6.17 et r8169.c
Date: Mon, 11 Sep 2006 13:09:08 +0200
Message-ID: <200609111309.08447.corentincj@iksaif.net>
References: <200609091201.03603.corentincj@iksaif.net> <200609091451.14579.corentincj@iksaif.net> <20060910214254.GA22831@electric-eye.fr.zoreil.com>
Reply-To: corentincj@iksaif.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iksaif.dns26.com ([84.246.226.15]:15256 "EHLO iksaif.net")
	by vger.kernel.org with ESMTP id S932088AbWIKLIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 07:08:55 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060910214254.GA22831@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the 2.6.17 Patchs :

xfport /usr/src/linux # insmod drivers/net/r8169.ko
xfport /usr/src/linux # dmesg | tail
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:02:00.0 to 64
eth0: RTL8168b/8111b at 0xf0fe6000, 00:17:31:c1:8d:ee, IRQ 16
r8169: eth0: link down
r8169: eth0: link down
r8169: eth0: link up
xfport /usr/src/linux # ifconfig eth0 up
xfport /usr/src/linux # ifconfig eth0 192.168.0.20
xfport /usr/src/linux # mii-tool eth0
SIOCGMIIPHY on 'eth0' failed: Operation not supported
xfport /usr/src/linux # ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.

--- 192.168.0.2 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms
xfport /usr/src/linux # ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
        Link detected: yes


With NET_IP_ALIGN + 6 : It does *exactly* the same thing, *but* it works 
perfectly !!!
So I now use that, but I test 2.6.18 patchs.


With the  2.6.18 kernel patchs :
same thing as before but mii-tool works (i think i forget patchs 10 and 11 
last time, sry).
BUT: i can't ping .. maybe it's just because I don't use mii-tool in the right 
way :(

(patch, make, insmod, ifconfig, exactly like before)

xfport /usr/src/linux # mii-tool eth0
eth0: negotiated 100baseTx-FD flow-control, link ok
xfport /usr/src/linux # mii-diag
Using the default interface 'eth0'.
Basic registers of MII PHY #32:  1000 796d 001c c912 0de1 45e1 0005 2001.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x1000: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx 
10baseT-FD 10baseT, w/ 802.3X                      flow control.
   End of basic transceiver information.
xfport /usr/src/linux # ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.

--- 192.168.0.2 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms


-- 
CHARY 'Iksaif' Corentin
iksaif@gmail.com - corentincj@yahoo.fr
http://xf.iksaif.net
