From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tg3 appears to be sick in 2.6.33
Date: Thu, 07 Jan 2010 23:24:44 +0100
Message-ID: <4B465F2C.1080208@gmail.com>
References: <201001071156.31892.dmitry.torokhov@gmail.com> <20100107204835.GB5788@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47219 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab0AGWYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 17:24:49 -0500
In-Reply-To: <20100107204835.GB5788@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/01/2010 21:48, Matt Carlson a =E9crit :
> Nothing jumps to mind.  Let me see if I can repro this here.
>=20
> On Thu, Jan 07, 2010 at 11:56:31AM -0800, Dmitry Torokhov wrote:
>> Hi,
>>
>> Ever since I moved post 2.6.32 tg3 seems to be very sick in my Latit=
ude
>> D630, it discards most of the packages for some reason:
>>
>> [root@dtor-d630 ~]# ethtool -S eth0 | grep rx_
>>      rx_octets: 35886
>>      rx_fragments: 0
>>      rx_ucast_packets: 9
>>      rx_mcast_packets: 93
>>      rx_bcast_packets: 237
>>      rx_fcs_errors: 0
>>      rx_align_errors: 0
>>      rx_xon_pause_rcvd: 0
>>      rx_xoff_pause_rcvd: 0
>>      rx_mac_ctrl_rcvd: 0
>>      rx_xoff_entered: 0
>>      rx_frame_too_long_errors: 0
>>      rx_jabbers: 0
>>      rx_undersize_packets: 0
>>      rx_in_length_errors: 0
>>      rx_out_length_errors: 0
>>      rx_64_or_less_octet_packets: 0
>>      rx_65_to_127_octet_packets: 0
>>      rx_128_to_255_octet_packets: 0
>>      rx_256_to_511_octet_packets: 0
>>      rx_512_to_1023_octet_packets: 0
>>      rx_1024_to_1522_octet_packets: 0
>>      rx_1523_to_2047_octet_packets: 0
>>      rx_2048_to_4095_octet_packets: 0
>>      rx_4096_to_8191_octet_packets: 0
>>      rx_8192_to_9022_octet_packets: 0
>>      rx_discards: 304
>>      rx_errors: 0
>>      rx_threshold_hit: 0
>>
>> The above on last night pull from Linux (so 2.6.33+).
>>
>> Everything works fine if I use wireless or another wired card (Realt=
ek in=20
>> cardbus slot):
>>
>> [root@dtor-d630 ~]# lspci | grep -ri net
>> 04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.=20
>> RTL-8139/8139C/8139C+ (rev 10)
>> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M=
 Gigabit=20
>> Ethernet PCI Express (rev 02)
>> 0c:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG [=
Golan]=20
>> Network Connection (rev 02)
>>
>> [root@dtor-d630 ~]# ethtool eth0
>> Settings for eth0:
>>         Supported ports: [ TP ]
>>         Supported link modes:   10baseT/Half 10baseT/Full
>>                                 100baseT/Half 100baseT/Full
>>                                 1000baseT/Half 1000baseT/Full
>>         Supports auto-negotiation: Yes
>>         Advertised link modes:  10baseT/Half 10baseT/Full
>>                                 100baseT/Half 100baseT/Full
>>                                 1000baseT/Half 1000baseT/Full
>>         Advertised auto-negotiation: Yes
>>         Speed: 1000Mb/s
>>         Duplex: Full
>>         Port: Twisted Pair
>>         PHYAD: 1
>>         Transceiver: internal
>>         Auto-negotiation: on
>>         Supports Wake-on: g
>>         Wake-on: g
>>         Current message level: 0x000000ff (255)
>>         Link detected: yes
>>
>> Any ideas? Thanks!
>>
>> --=20
>> Dmitry
>>
>=20

My laptop is a D630, and running 2.6.33-rc3 with no special problems on=
 tg3

root@edumazet-laptop:~# ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full=20
	                        100baseT/Half 100baseT/Full=20
	                        1000baseT/Half 1000baseT/Full=20
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full=20
	                        100baseT/Half 100baseT/Full=20
	                        1000baseT/Half 1000baseT/Full=20
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: g
	Wake-on: g
	Current message level: 0x000000ff (255)
	Link detected: yes

root@edumazet-laptop:~# ethtool -S eth0 | grep rx
     rx_octets: 13542409
     rx_fragments: 0
     rx_ucast_packets: 12253
     rx_mcast_packets: 0
     rx_bcast_packets: 17
     rx_fcs_errors: 0
     rx_align_errors: 0
     rx_xon_pause_rcvd: 0
     rx_xoff_pause_rcvd: 0
     rx_mac_ctrl_rcvd: 0
     rx_xoff_entered: 0
     rx_frame_too_long_errors: 0
     rx_jabbers: 0
     rx_undersize_packets: 0
     rx_in_length_errors: 0
     rx_out_length_errors: 0
     rx_64_or_less_octet_packets: 0
     rx_65_to_127_octet_packets: 0
     rx_128_to_255_octet_packets: 0
     rx_256_to_511_octet_packets: 0
     rx_512_to_1023_octet_packets: 0
     rx_1024_to_1522_octet_packets: 0
     rx_1523_to_2047_octet_packets: 0
     rx_2048_to_4095_octet_packets: 0
     rx_4096_to_8191_octet_packets: 0
     rx_8192_to_9022_octet_packets: 0
     rxbds_empty: 0
     rx_discards: 0
     rx_errors: 0
     rx_threshold_hit: 0

# dmesg | grep tg3
[    4.085259] tg3.c:v3.105 (December 2, 2009)
[    4.085282] tg3 0000:09:00.0: PCI INT A -> GSI 17 (level, low) -> IR=
Q 17
[    4.085296] tg3 0000:09:00.0: setting latency timer to 64
[   10.910756] tg3 0000:09:00.0: irq 28 for MSI/MSI-X
[   12.554801] tg3: eth0: Link is up at 100 Mbps, full duplex.
[   12.554805] tg3: eth0: Flow control is on for TX and on for RX.

# uname -a
Linux edumazet-laptop 2.6.33-rc3 #15 SMP Thu Jan 7 22:11:49 CET 2010 x8=
6_64 GNU/Linux
