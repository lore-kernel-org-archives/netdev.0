From: "Thomas A. Oehser" <tom@toms.net>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Sun, 16 Apr 2006 13:26:39 -0400
Message-ID: <20060416172639.GA12243@jupiter.toms.net>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com> <20060416134201.GA2681@jupiter.toms.net> <20060416144354.GA11433@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Thomas A. Oehser" <tom@toms.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.toms.net ([207.145.105.50]:48552 "EHLO jupiter.toms.net")
	by vger.kernel.org with ESMTP id S1750763AbWDPR0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2006 13:26:48 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060416144354.GA11433@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'll welcome a complete dmesg after you have recovered through
> ifconfig down/up though.

_Nothing_ on dmesg.

> No problem. One more question: have you enabled NAPI ? If not, you
> should.

Doesn't seem to make a difference.  Here, with it on, after failing it:

  --- 192.168.99.100 ping statistics ---
  1362 packets transmitted, 903 packets received, 33% packet loss
  round-trip min/avg/max = 0.1/35803.4/65264.8 ms

Worse than I thought, to a machine on the same gigabit copper switch...

ifconfig eth1:

eth1      Link encap:Ethernet  HWaddr 00:E0:4C:13:A9:56  
          inet addr:192.168.99.99  Bcast:192.168.99.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:528416 errors:252 dropped:620 overruns:0 frame:966
          TX packets:243040 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          Interrupt:161 Base address:0xe000 

ethtool eth1:

Settings for eth1:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000033 (51)
	Link detected: yes

Note, without having thrown traffic through it, I have:

PING 192.168.99.100 (192.168.99.100): 56 data bytes
64 bytes from 192.168.99.100: icmp_seq=0 ttl=128 time=0.1 ms
64 bytes from 192.168.99.100: icmp_seq=1 ttl=128 time=0.1 ms
64 bytes from 192.168.99.100: icmp_seq=2 ttl=128 time=0.1 ms
64 bytes from 192.168.99.100: icmp_seq=3 ttl=128 time=0.1 ms
--- 192.168.99.100 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.1/0.1/0.1 ms

What next?

-Tom
