From: Brent Cook <bcook@breakingpoint.com>
Subject: Occasional link flap on Intel 82599 on boot in XAUI mode
Date: Fri, 25 Feb 2011 10:11:42 -0600
Message-ID: <201102251011.42400.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:41925 "EHLO
	EXCHANGE.securitytestsystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932475Ab1BYQL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 11:11:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a custom system with dual 82599's in XAUI mode. One has its pair of ports connected to a 10G switch, the other has its pair of ports connected to an FPGA.

Occasionally, on any of the interfaces, we will see the links flapping up and down when the system initially boots. This happens maybe one in 20 boots.

Feb 23 14:58:10 mfg kernel: [  594.254977] ixgbe: eth1 NIC Link is Down
Feb 23 14:58:12 mfg kernel: [  596.230039] ixgbe: eth1 NIC Link is Up 10 Gbps, Flow Control: RX/TX
Feb 23 14:58:12 mfg kernel: [  596.256537] ixgbe: eth1 NIC Link is Down
Feb 23 14:58:16 mfg kernel: [  600.228096] ixgbe: eth1 NIC Link is Up 10 Gbps, Flow Control: RX/TX
Feb 23 14:58:16 mfg kernel: [  600.240135] ixgbe: eth1 NIC Link is Down
Feb 23 14:58:18 mfg kernel: [  602.227047] ixgbe: eth1 NIC Link is Up 10 Gbps, Flow Control: RX/TX

Simply forcing a down/up on the interface seems to correct the problem:

ip link set eth1 down
ip link set eth1 up

Is anyone else using XAUI mode and has seen this? Here is the kernel information that we are using currently:

Linux sprint.labnet.local 2.6.32.28-bps #1 SMP PREEMPT Mon Jan 31 16:05:50 CST 2011 x86_64 GNU/Linux

Feb 23 14:48:24 mfg kernel: [    3.488664] Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI
Feb 23 14:48:24 mfg kernel: [    3.495082] Copyright (c) 1999-2006 Intel Corporation.
Feb 23 14:48:24 mfg kernel: [    3.500238] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
Feb 23 14:48:24 mfg kernel: [    3.506138] e1000e: Copyright (c) 1999-2008 Intel Corporation.
Feb 23 14:48:24 mfg kernel: [    3.511988] Intel(R) Gigabit Ethernet Network Driver - version 1.3.16-k2
Feb 23 14:48:24 mfg kernel: [    3.518666] Copyright (c) 2007-2009 Intel Corporation.
Feb 23 14:48:24 mfg kernel: [    3.523817] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.44-k2
Feb 23 14:48:24 mfg kernel: [    3.531622] ixgbe: Copyright (c) 1999-2009 Intel Corporation.
Feb 23 14:48:24 mfg kernel: [    3.537365] ixgbe 0000:01:00.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
Feb 23 14:48:24 mfg kernel: [    3.632934] ixgbe: 0000:01:00.0: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
Feb 23 14:48:24 mfg kernel: [    3.643769] ixgbe 0000:01:00.0: (PCI Express:5.0Gb/s:Width x8) 00:12:34:56:78:67
Feb 23 14:48:24 mfg kernel: [    3.651221] ixgbe 0000:01:00.0: MAC: 2, PHY: 0, PBA No: ffffff-0ff
Feb 23 14:48:24 mfg kernel: [    3.669390] ixgbe 0000:01:00.0: Intel(R) 10 Gigabit Network Connection
Feb 23 14:48:24 mfg kernel: [    3.675907] ixgbe 0000:01:00.1: PCI INT B -> GSI 47 (level, low) -> IRQ 47
Feb 23 14:48:24 mfg kernel: [    3.771863] ixgbe: 0000:01:00.1: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
Feb 23 14:48:24 mfg kernel: [    3.782699] ixgbe 0000:01:00.1: (PCI Express:5.0Gb/s:Width x8) 00:12:34:56:78:64
Feb 23 14:48:24 mfg kernel: [    3.790151] ixgbe 0000:01:00.1: MAC: 2, PHY: 0, PBA No: ffffff-0ff
Feb 23 14:48:24 mfg kernel: [    3.808314] ixgbe 0000:01:00.1: Intel(R) 10 Gigabit Network Connection
Feb 23 14:48:24 mfg kernel: [    3.814831] ixgbe 0000:02:00.0: PCI INT A -> GSI 35 (level, low) -> IRQ 35
Feb 23 14:48:24 mfg kernel: [    3.910802] ixgbe: 0000:02:00.0: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
Feb 23 14:48:24 mfg kernel: [    3.921636] ixgbe 0000:02:00.0: (PCI Express:5.0Gb/s:Width x8) 00:12:34:56:78:52
Feb 23 14:48:24 mfg kernel: [    3.929087] ixgbe 0000:02:00.0: MAC: 2, PHY: 0, PBA No: ffffff-0ff
Feb 23 14:48:24 mfg kernel: [    3.947246] ixgbe 0000:02:00.0: Intel(R) 10 Gigabit Network Connection
Feb 23 14:48:24 mfg kernel: [    3.953761] ixgbe 0000:02:00.1: PCI INT B -> GSI 36 (level, low) -> IRQ 36
Feb 23 14:48:24 mfg kernel: [    4.049731] ixgbe: 0000:02:00.1: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
Feb 23 14:48:24 mfg kernel: [    4.060566] ixgbe 0000:02:00.1: (PCI Express:5.0Gb/s:Width x8) 00:12:34:56:78:53
Feb 23 14:48:24 mfg kernel: [    4.068018] ixgbe 0000:02:00.1: MAC: 2, PHY: 0, PBA No: ffffff-0ff
Feb 23 14:48:24 mfg kernel: [    4.086179] ixgbe 0000:02:00.1: Intel(R) 10 Gigabit Network Connection
