From: Ben Greear <greearb@candelatech.com>
Subject: Detected Tx Unit Hang in ixgbe, kernel 2.6.25
Date: Tue, 06 May 2008 10:04:29 -0700
Message-ID: <48208F9D.1080608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:43253 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbYEFREb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 13:04:31 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m46H4TpD010172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 May 2008 10:04:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using a 10Gbps copper(CX4) dual-port NIC from silicomusa.com.
It uses the Intel chipset and ixgbe driver.  I'm using
kernel 2.6.25 plus some hacks (no patches to ixgbe).

This particular test case was to create 500 mac-vlans on
each of the two ports and generate UDP traffic between
them (I have a version of the send-to-self patch applied
to my kernel and enabled.)

During the setup for this test, the interfaces would have
been bounced (effectively ifdown, ifup), so that is the
reason for the link going up and down.

I noticed 90%+ drop rate when I first started the test,
and then after maybe 1-2 minutes, things calmed down and
started working.  I checked /var/log/messages and saw the
messages below.

I previously ran 5Gbps of traffic through the two ports
with them acting like a bridge for more than 24-hours without
any obvious problems, so I think the hardware is probably OK.

May  6 09:51:41 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:41 simech-ice kernel:   TDH                  <1e>
May  6 09:51:41 simech-ice kernel:   TDT                  <3ff>
May  6 09:51:41 simech-ice kernel:   next_to_use          <3ff>
May  6 09:51:41 simech-ice kernel:   next_to_clean        <1a>
May  6 09:51:41 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:41 simech-ice kernel:   time_stamp           <11e035210>
May  6 09:51:41 simech-ice kernel:   next_to_watch        <1b>
May  6 09:51:41 simech-ice kernel:   jiffies              <11e035862>
May  6 09:51:41 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:41 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:41 simech-ice kernel:   TDH                  <3d6>
May  6 09:51:41 simech-ice kernel:   TDT                  <3b0>
May  6 09:51:41 simech-ice kernel:   next_to_use          <3b0>
May  6 09:51:41 simech-ice kernel:   next_to_clean        <3d2>
May  6 09:51:41 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:41 simech-ice kernel:   time_stamp           <11e035211>
May  6 09:51:41 simech-ice kernel:   next_to_watch        <3d3>
May  6 09:51:41 simech-ice kernel:   jiffies              <11e035887>
May  6 09:51:41 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:46 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:46 simech-ice kernel:   TDH                  <28d>
May  6 09:51:46 simech-ice kernel:   TDT                  <26c>
May  6 09:51:46 simech-ice kernel:   next_to_use          <26c>
May  6 09:51:46 simech-ice kernel:   next_to_clean        <289>
May  6 09:51:46 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:46 simech-ice kernel:   time_stamp           <11e0363e0>
May  6 09:51:46 simech-ice kernel:   next_to_watch        <28a>
May  6 09:51:46 simech-ice kernel:   jiffies              <11e036e8e>
May  6 09:51:46 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:46 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:46 simech-ice kernel:   TDH                  <1bd>
May  6 09:51:46 simech-ice kernel:   TDT                  <19c>
May  6 09:51:46 simech-ice kernel:   next_to_use          <19c>
May  6 09:51:46 simech-ice kernel:   next_to_clean        <1b9>
May  6 09:51:46 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:46 simech-ice kernel:   time_stamp           <11e036346>
May  6 09:51:46 simech-ice kernel:   next_to_watch        <1ba>
May  6 09:51:46 simech-ice kernel:   jiffies              <11e036e9a>
May  6 09:51:46 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:47 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:47 simech-ice kernel:   TDH                  <29e>
May  6 09:51:47 simech-ice kernel:   TDT                  <27c>
May  6 09:51:47 simech-ice kernel:   next_to_use          <27c>
May  6 09:51:47 simech-ice kernel:   next_to_clean        <29a>
May  6 09:51:47 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:47 simech-ice kernel:   time_stamp           <11e0363e0>
May  6 09:51:47 simech-ice kernel:   next_to_watch        <29b>
May  6 09:51:47 simech-ice kernel:   jiffies              <11e036fee>
May  6 09:51:47 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:47 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:47 simech-ice kernel:   TDH                  <33f>
May  6 09:51:47 simech-ice kernel:   TDT                  <321>
May  6 09:51:47 simech-ice kernel:   next_to_use          <321>
May  6 09:51:47 simech-ice kernel:   next_to_clean        <33b>
May  6 09:51:47 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:47 simech-ice kernel:   time_stamp           <11e0363e2>
May  6 09:51:47 simech-ice kernel:   next_to_watch        <33c>
May  6 09:51:47 simech-ice kernel:   jiffies              <11e036ff5>
May  6 09:51:47 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:51 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:51 simech-ice kernel:   TDH                  <398>
May  6 09:51:51 simech-ice kernel:   TDT                  <374>
May  6 09:51:51 simech-ice kernel:   next_to_use          <374>
May  6 09:51:51 simech-ice kernel:   next_to_clean        <394>
May  6 09:51:51 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:51 simech-ice kernel:   time_stamp           <11e037748>
May  6 09:51:51 simech-ice kernel:   next_to_watch        <395>
May  6 09:51:51 simech-ice kernel:   jiffies              <11e038251>
May  6 09:51:51 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:51:51 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:51:51 simech-ice kernel:   TDH                  <101>
May  6 09:51:51 simech-ice kernel:   TDT                  <dd>
May  6 09:51:51 simech-ice kernel:   next_to_use          <dd>
May  6 09:51:51 simech-ice kernel:   next_to_clean        <fd>
May  6 09:51:51 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:51:51 simech-ice kernel:   time_stamp           <11e037743>
May  6 09:51:51 simech-ice kernel:   next_to_watch        <fe>
May  6 09:51:51 simech-ice kernel:   jiffies              <11e03825c>
May  6 09:51:51 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:00 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:00 simech-ice kernel:   TDH                  <2b5>
May  6 09:52:00 simech-ice kernel:   TDT                  <292>
May  6 09:52:00 simech-ice kernel:   next_to_use          <292>
May  6 09:52:00 simech-ice kernel:   next_to_clean        <2b1>
May  6 09:52:00 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:00 simech-ice kernel:   time_stamp           <11e038937>
May  6 09:52:00 simech-ice kernel:   next_to_watch        <2b2>
May  6 09:52:00 simech-ice kernel:   jiffies              <11e03a29c>
May  6 09:52:00 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:00 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:00 simech-ice kernel:   TDH                  <8>
May  6 09:52:00 simech-ice kernel:   TDT                  <3e6>
May  6 09:52:00 simech-ice kernel:   next_to_use          <3e6>
May  6 09:52:00 simech-ice kernel:   next_to_clean        <4>
May  6 09:52:00 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:00 simech-ice kernel:   time_stamp           <11e038957>
May  6 09:52:00 simech-ice kernel:   next_to_watch        <5>
May  6 09:52:00 simech-ice kernel:   jiffies              <11e03a2d5>
May  6 09:52:00 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:11 simech-ice kernel: NETDEV WATCHDOG: eth3: transmit timed out
May  6 09:52:11 simech-ice kernel: NETDEV WATCHDOG: eth2: transmit timed out
May  6 09:52:11 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Down
May  6 09:52:11 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:11 simech-ice kernel:   TDH                  <18c>
May  6 09:52:11 simech-ice kernel:   TDT                  <12a>
May  6 09:52:11 simech-ice kernel:   next_to_use          <12a>
May  6 09:52:11 simech-ice kernel:   next_to_clean        <188>
May  6 09:52:11 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:11 simech-ice kernel:   time_stamp           <11e03aa83>
May  6 09:52:11 simech-ice kernel:   next_to_watch        <189>
May  6 09:52:11 simech-ice kernel:   jiffies              <11e03cde1>
May  6 09:52:11 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:11 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:11 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Down
May  6 09:52:11 simech-ice kernel: ADDRCONF(NETDEV_UP): eth3#435: link is not ready
May  6 09:52:11 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:11 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:11 simech-ice kernel: ADDRCONF(NETDEV_CHANGE): eth3#435: link becomes ready
May  6 09:52:22 simech-ice kernel: NETDEV WATCHDOG: eth3: transmit timed out
May  6 09:52:22 simech-ice kernel: NETDEV WATCHDOG: eth2: transmit timed out
May  6 09:52:23 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Down
May  6 09:52:23 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:23 simech-ice kernel:   TDH                  <19b>
May  6 09:52:23 simech-ice kernel:   TDT                  <173>
May  6 09:52:23 simech-ice kernel:   next_to_use          <173>
May  6 09:52:23 simech-ice kernel:   next_to_clean        <197>
May  6 09:52:23 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:23 simech-ice kernel:   time_stamp           <11e03d200>
May  6 09:52:23 simech-ice kernel:   next_to_watch        <198>
May  6 09:52:23 simech-ice kernel:   jiffies              <11e03fcd1>
May  6 09:52:23 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:23 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:23 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Down
May  6 09:52:23 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:23 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Down
May  6 09:52:23 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:23 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Down
May  6 09:52:23 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:23 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:27 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:27 simech-ice kernel:   TDH                  <6>
May  6 09:52:27 simech-ice kernel:   TDT                  <3e4>
May  6 09:52:27 simech-ice kernel:   next_to_use          <3e4>
May  6 09:52:27 simech-ice kernel:   next_to_clean        <2>
May  6 09:52:27 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:27 simech-ice kernel:   time_stamp           <11e0400bb>
May  6 09:52:27 simech-ice kernel:   next_to_watch        <3>
May  6 09:52:27 simech-ice kernel:   jiffies              <11e040d75>
May  6 09:52:27 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:34 simech-ice kernel: NETDEV WATCHDOG: eth3: transmit timed out
May  6 09:52:34 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Down
May  6 09:52:34 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:34 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Down
May  6 09:52:34 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:34 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:42 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:42 simech-ice kernel:   TDH                  <189>
May  6 09:52:42 simech-ice kernel:   TDT                  <159>
May  6 09:52:42 simech-ice kernel:   next_to_use          <159>
May  6 09:52:42 simech-ice kernel:   next_to_clean        <184>
May  6 09:52:42 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:42 simech-ice kernel:   time_stamp           <11e042edb>
May  6 09:52:42 simech-ice kernel:   next_to_watch        <185>
May  6 09:52:42 simech-ice kernel:   jiffies              <11e0449ec>
May  6 09:52:42 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:45 simech-ice kernel: NETDEV WATCHDOG: eth2: transmit timed out
May  6 09:52:48 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:48 simech-ice kernel:   TDH                  <d>
May  6 09:52:48 simech-ice kernel:   TDT                  <3e6>
May  6 09:52:48 simech-ice kernel:   next_to_use          <3e6>
May  6 09:52:48 simech-ice kernel:   next_to_clean        <9>
May  6 09:52:48 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:48 simech-ice kernel:   time_stamp           <11e042de5>
May  6 09:52:48 simech-ice kernel:   next_to_watch        <a>
May  6 09:52:48 simech-ice kernel:   jiffies              <11e045e0b>
May  6 09:52:48 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:48 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:52:48 simech-ice kernel:   TDH                  <78>
May  6 09:52:48 simech-ice kernel:   TDT                  <52>
May  6 09:52:48 simech-ice kernel:   next_to_use          <52>
May  6 09:52:48 simech-ice kernel:   next_to_clean        <73>
May  6 09:52:48 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:52:48 simech-ice kernel:   time_stamp           <11e042e11>
May  6 09:52:48 simech-ice kernel:   next_to_watch        <74>
May  6 09:52:48 simech-ice kernel:   jiffies              <11e045e7c>
May  6 09:52:48 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:52:48 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Down
May  6 09:52:48 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:48 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Down
May  6 09:52:48 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:48 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:59 simech-ice kernel: NETDEV WATCHDOG: eth3: transmit timed out
May  6 09:52:59 simech-ice kernel: NETDEV WATCHDOG: eth2: transmit timed out
May  6 09:52:59 simech-ice kernel: ixgbe: eth2: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:52:59 simech-ice kernel: ixgbe: eth3: ixgbe_watchdog: NIC Link is Up 10 Gbps, Flow Control: RX/TX
May  6 09:53:07 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:53:07 simech-ice kernel:   TDH                  <28>
May  6 09:53:07 simech-ice kernel:   TDT                  <3>
May  6 09:53:07 simech-ice kernel:   next_to_use          <3>
May  6 09:53:07 simech-ice kernel:   next_to_clean        <23>
May  6 09:53:07 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:53:07 simech-ice kernel:   time_stamp           <11e049a4d>
May  6 09:53:07 simech-ice kernel:   next_to_watch        <24>
May  6 09:53:07 simech-ice kernel:   jiffies              <11e04a866>
May  6 09:53:07 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:53:07 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:53:07 simech-ice kernel:   TDH                  <2ad>
May  6 09:53:07 simech-ice kernel:   TDT                  <28c>
May  6 09:53:07 simech-ice kernel:   next_to_use          <28c>
May  6 09:53:07 simech-ice kernel:   next_to_clean        <2a7>
May  6 09:53:07 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:53:07 simech-ice kernel:   time_stamp           <11e04979e>
May  6 09:53:07 simech-ice kernel:   next_to_watch        <2a8>
May  6 09:53:07 simech-ice kernel:   jiffies              <11e04a880>
May  6 09:53:07 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:53:10 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:53:10 simech-ice kernel:   TDH                  <129>
May  6 09:53:10 simech-ice kernel:   TDT                  <103>
May  6 09:53:10 simech-ice kernel:   next_to_use          <103>
May  6 09:53:10 simech-ice kernel:   next_to_clean        <125>
May  6 09:53:10 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:53:10 simech-ice kernel:   time_stamp           <11e04b236>
May  6 09:53:10 simech-ice kernel:   next_to_watch        <126>
May  6 09:53:10 simech-ice kernel:   jiffies              <11e04b61f>
May  6 09:53:10 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:53:14 simech-ice kernel: ixgbe: eth3: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:53:14 simech-ice kernel:   TDH                  <18e>
May  6 09:53:14 simech-ice kernel:   TDT                  <165>
May  6 09:53:14 simech-ice kernel:   next_to_use          <165>
May  6 09:53:14 simech-ice kernel:   next_to_clean        <189>
May  6 09:53:14 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:53:14 simech-ice kernel:   time_stamp           <11e04b24c>
May  6 09:53:14 simech-ice kernel:   next_to_watch        <18a>
May  6 09:53:14 simech-ice kernel:   jiffies              <11e04c4e4>
May  6 09:53:14 simech-ice kernel:   next_to_watch.status <17a8209>
May  6 09:53:14 simech-ice kernel: ixgbe: eth2: ixgbe_check_tx_hang: Detected Tx Unit Hang
May  6 09:53:14 simech-ice kernel:   TDH                  <3b>
May  6 09:53:14 simech-ice kernel:   TDT                  <16>
May  6 09:53:14 simech-ice kernel:   next_to_use          <16>
May  6 09:53:14 simech-ice kernel:   next_to_clean        <37>
May  6 09:53:14 simech-ice kernel: tx_buffer_info[next_to_clean]
May  6 09:53:14 simech-ice kernel:   time_stamp           <11e04b1d7>
May  6 09:53:14 simech-ice kernel:   next_to_watch        <38>
May  6 09:53:14 simech-ice kernel:   jiffies              <11e04c6e3>
May  6 09:53:14 simech-ice kernel:   next_to_watch.status <17a8209>


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

