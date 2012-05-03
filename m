From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: sky2 still badly broken
Date: Thu, 03 May 2012 21:26:52 +0200
Message-ID: <4FA2DBFC.5010505@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net> <4FA14EC6.6050207@linuxsystems.it> <20120502115618.04ab8ff9@s6510.linuxnetplumber.net> <4FA2527A.6020808@linuxsystems.it> <20120503082352.771acab3@nehalam.linuxnetplumber.net> <4FA2C913.4080504@linuxsystems.it> <20120503111536.269490e3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:47586 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347Ab2ECTZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 15:25:46 -0400
In-Reply-To: <20120503111536.269490e3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 03/05/2012 20:15, Stephen Hemminger ha scritto:
> Maybe ethtool registers have some info?
>
> # ethtool -S eth0

After:
64 bytes from 8.8.8.8: icmp_req=3D592 ttl=3D47 time=3D61.0 ms
64 bytes from 8.8.8.8: icmp_req=3D593 ttl=3D47 time=3D64.9 ms
64 bytes from 8.8.8.8: icmp_req=3D594 ttl=3D47 time=3D61.8 ms
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
[...]

I get:

laptop ~ # ethtool eth0
Settings for eth0:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  100baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 100Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 0
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: Unknown
         Supports Wake-on: pg
         Wake-on: g
         Current message level: 0x000000ff (255)
                                drv probe link timer ifdown ifup rx_err=
=20
tx_err
         Link detected: yes
laptop ~ # ethtool -S eth0
NIC statistics:
      tx_bytes: 118170
      rx_bytes: 891033
      tx_broadcast: 36
      rx_broadcast: 346
      tx_multicast: 4
      rx_multicast: 332
      tx_unicast: 1131
      rx_unicast: 1235
      tx_mac_pause: 0
      rx_mac_pause: 0
      collisions: 0
      late_collision: 0
      aborted: 0
      single_collisions: 0
      multi_collisions: 0
      rx_short: 0
      rx_runt: 0
      rx_64_byte_packets: 344
      rx_65_to_127_byte_packets: 654
      rx_128_to_255_byte_packets: 362
      rx_256_to_511_byte_packets: 50
      rx_512_to_1023_byte_packets: 11
      rx_1024_to_1518_byte_packets: 492
      rx_1518_to_max_byte_packets: 0
      rx_too_long: 0
      rx_fifo_overflow: 0
      rx_jabber: 0
      rx_fcs_error: 0
      tx_64_byte_packets: 45
      tx_65_to_127_byte_packets: 1074
      tx_128_to_255_byte_packets: 0
      tx_256_to_511_byte_packets: 52
      tx_512_to_1023_byte_packets: 0
      tx_1024_to_1518_byte_packets: 0
      tx_1519_to_max_byte_packets: 0
      tx_fifo_underrun: 0

> And if you enable the debugfs option there is more info
> hidden there.
>
> # mount -t debugfs debugfs /sys/kernel/debug
> # cat /sys/kernel/debug/sky2/eth0

There is no sky2 directory, maybe I don't have enough debug options in=20
my kernel config.

Niccol=F2
