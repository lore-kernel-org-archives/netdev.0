From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sk98lin for 2.6.23-rc1
Date: Fri, 27 Jul 2007 20:27:07 +0100
Message-ID: <6278d2220707271227g51cb147ch2f6dbc05c73f618d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:17058 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758445AbXG0T1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 15:27:09 -0400
Received: by wr-out-0506.google.com with SMTP id i30so558926wra
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2007 12:27:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If anyone still has hang issues with sky2, please send me the hardware
> information (lspci, dmesg output), and capture the debugfs state after hang.
>
> At present the known open skge, sky2 issues are:
[snip]

There is still this active issue which I believe is orthogonal from
the interrupt hang. I just hit it again. The IRQ-hang recovery logic
doesn't seem to kick in, so it's perhaps another issue:

# ifconfig lan0
lan0      Link encap:Ethernet  HWaddr 00:03:2D:05:9C:27
          inet addr:192.168.0.250  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13304841 errors:1 dropped:1 overruns:0 frame:2
          TX packets:7493765 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:232720755 (221.9 MiB)  TX bytes:3964088142 (3.6 GiB)
          Interrupt:16

# ethtool -S lan0
NIC statistics:
     tx_bytes: 44342166229
     rx_bytes: 28807483162
     tx_broadcast: 20071
     rx_broadcast: 3309
     tx_multicast: 0
     rx_multicast: 31
     tx_unicast: 45095221
     rx_unicast: 43331790
     tx_mac_pause: 0
     rx_mac_pause: 278
     collisions: 0
     late_collision: 0
     aborted: 0
     single_collisions: 0
     multi_collisions: 0
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 1815009
     rx_65_to_127_byte_packets: 18626585
     rx_128_to_255_byte_packets: 788459
     rx_256_to_511_byte_packets: 4880174
     rx_512_to_1023_byte_packets: 1016831
     rx_1024_to_1518_byte_packets: 16208350
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 1632797
     tx_65_to_127_byte_packets: 11211285
     tx_128_to_255_byte_packets: 1628446
     tx_256_to_511_byte_packets: 2042646
     tx_512_to_1023_byte_packets: 637342
     tx_1024_to_1518_byte_packets: 27962776
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0

# dmesg
[snip]
sky2 0000:01:00.0: v1.16 addr 0xdfbfc000 irq 16 Yukon-EC (0xb6) rev 1
sky2 eth1: addr 00:03:2d:05:9c:27
sky2 lan0: enabling interface
sky2 lan0: ram buffer 48K
[snip]
sky2 lan0: rx error, status 0xad78ad78 length 0
lan0: hw csum failure.
[stack-trace snipped]
lan0: hw csum failure.
...

# cat /debug/sky2/lan0
IRQ src=0 mask=c000001d control=0
Status ring (empty)
Tx ring pending=424...424 report=424 done=424

Rx ring hw get=252 put=405 last=1023

# cat /debug/sky2/lan0
IRQ src=0 mask=c000001d control=0
Status ring (empty)
Tx ring pending=432...432 report=432 done=432

Rx ring hw get=252 put=415 last=1023

# cat /debug/sky2/lan0
IRQ src=0 mask=c000001d control=0
Status ring (empty)
Tx ring pending=451...451 report=451 done=451

Rx ring hw get=316 put=440 last=1023
-- 
Daniel J Blueman
