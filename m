From: Amr Bekhit <amrbekhit@gmail.com>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Mon, 9 May 2016 11:01:21 +0100
Message-ID: <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com> <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37981 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbcEIKBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 06:01:42 -0400
Received: by mail-wm0-f41.google.com with SMTP id g17so177171104wme.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 03:01:42 -0700 (PDT)
In-Reply-To: <20160503153659.GA29815@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Based on the information I pasted below, it appears that
autonegotiation is working - the device detects that there is a link
partner connected and ethtool reports back the various link modes that
can be used. I'm not sure about the status bits - I couldn't find out
how I would check them.

The test results are as follows - I've carried out the following test
on a freshly booted system with the ethernet cable initially
unplugged:

# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 70:B3:D5:BA:B8:90
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:39 Base address:0xc000
# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: Unknown!
        Duplex: Unknown! (255)
        Port: MII
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Link detected: no

--------------------------------------------------------------------
Now the ethernet cable is plugged in and the network interface brought up:

# ifconfig eth0 up
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
# macb f802c000.ethernet eth0: link up (100/Full)
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 70:B3:D5:BA:B8:90
          inet6 addr: fe80::72b3:d5ff:feba:b890%3068527384/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:39 Base address:0xc000

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                             100baseT/Half 100baseT/Full
        Link partner advertised pause frame use: Symmetric Receive-only
        Link partner advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Link detected: yes

-------------------------------------------------
Setting a static IP

# ifconfig eth0 192.168.100.200
# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 70:B3:D5:BA:B8:90
          inet addr:192.168.100.200  Bcast:192.168.100.255  Mask:255.255.255.0
          inet6 addr: fe80::72b3:d5ff:feba:b890%3067806488/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:39 Base address:0xc000

------------------------------------------------
Trying to ping and arping (I ctrl+C out of it after a while, as I do
not get any output):

# ping 192.168.100.100
PING 192.168.100.100 (192.168.100.100): 56 data bytes
^C
--- 192.168.100.100 ping statistics ---
24 packets transmitted, 0 packets received, 100% packet loss

# arping 192.168.100.100
ARPING to 192.168.100.100 from 192.168.100.200 via eth0
^CSent 19 probe(s) (19 broadcast(s))
Received 0 reply (0 request(s), 0 broadcast(s))


On 3 May 2016 at 16:36, Andrew Lunn <andrew@lunn.ch> wrote:
>> Any ideas as to why I can't get any packets out? Is there a way for me
>> to test whether there is an issue between the MAC and PHY?
>
> Does it perform auto-negotiate? If it does, the PHY to the cable is
> probably O.K.
>
> Have you checked the status bits. Loopback, Power down, Isolate?
>
>      Andrew
