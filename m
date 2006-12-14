From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 15:21:00 -0800
Message-ID: <87zm9qkqsj.fsf@sycorax.lbl.gov>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty> <87odq6azel.fsf@sycorax.lbl.gov>
	<20061214144734.03300fa6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:4083 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbWLNXVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 18:21:03 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061214144734.03300fa6@freekitty> (message from Stephen
	Hemminger on Thu, 14 Dec 2006 14:47:34 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> Another useful bit of information is the statistics (ethtool -S eth0).
> When there were flow control bugs, they would show up as count of 1.

the driver locked up again, even with msi interrupts disabled and
idle_timeout=10. the console message was pretty much as before:

kernel: NETDEV WATCHDOG: eth0: transmit timed out
kernel: sky2 eth0: tx timeout
kernel: sky2 eth0: transmit ring 336 .. 296 report=336 done=336
kernel: sky2 hardware hung? flushing
kernel: NETDEV WATCHDOG: eth0: transmit timed out
kernel: sky2 eth0: tx timeout
kernel: sky2 eth0: transmit ring 296 .. 255 report=336 done=336
kernel: sky2 status report lost?

and this is the output from ethtool -S:

NIC statistics:
     tx_bytes: 3092123897
     rx_bytes: 546577898
     tx_broadcast: 20
     rx_broadcast: 4376
     tx_multicast: 0
     rx_multicast: 459
     tx_unicast: 2585993
     rx_unicast: 1550758
     tx_mac_pause: 1
     rx_mac_pause: 0
     collisions: 0
     late_collision: 0
     aborted: 0
     single_collisions: 0
     multi_collisions: 0
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 850693
     rx_65_to_127_byte_packets: 297029
     rx_128_to_255_byte_packets: 62116
     rx_256_to_511_byte_packets: 28795
     rx_512_to_1023_byte_packets: 31357
     rx_1024_to_1518_byte_packets: 285603
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 194159
     tx_65_to_127_byte_packets: 239961
     tx_128_to_255_byte_packets: 48148
     tx_256_to_511_byte_packets: 27635
     tx_512_to_1023_byte_packets: 95557
     tx_1024_to_1518_byte_packets: 1980554
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0

time to try the vendor driver and see if that provides any clues.

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
