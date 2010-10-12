From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-next] bnx2x: all traffic comes to RX queue 0
Date: Tue, 12 Oct 2010 18:07:37 +0200
Message-ID: <1286899657.2732.93.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64610 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757425Ab0JLQHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 12:07:42 -0400
Received: by wyb28 with SMTP id 28so154140wyb.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 09:07:41 -0700 (PDT)
In-Reply-To: <1286838210.30423.128.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, while doing tests for the netdev_alloc_skb() problem, I found
current net-next tree is not really multi queue enabled...

ethtool -S eth1|grep _ucast
     [0]: rx_ucast_packets: 3507786
     [0]: tx_ucast_packets: 416925
     [1]: rx_ucast_packets: 0
     [1]: tx_ucast_packets: 4
     [2]: rx_ucast_packets: 0
     [2]: tx_ucast_packets: 397467
     [3]: rx_ucast_packets: 0
     [3]: tx_ucast_packets: 75832
     [4]: rx_ucast_packets: 0
     [4]: tx_ucast_packets: 171025
     [5]: rx_ucast_packets: 0
     [5]: tx_ucast_packets: 233025
     [6]: rx_ucast_packets: 0
     [6]: tx_ucast_packets: 250358
     [7]: rx_ucast_packets: 0
     [7]: tx_ucast_packets: 240792
     [8]: rx_ucast_packets: 0
     [8]: tx_ucast_packets: 216366
     [9]: rx_ucast_packets: 0
     [9]: tx_ucast_packets: 1
     [10]: rx_ucast_packets: 0
     [10]: tx_ucast_packets: 350324
     [11]: rx_ucast_packets: 0
     [11]: tx_ucast_packets: 92403
     [12]: rx_ucast_packets: 0
     [12]: tx_ucast_packets: 307678
     [13]: rx_ucast_packets: 0
     [13]: tx_ucast_packets: 314315
     [14]: rx_ucast_packets: 0
     [14]: tx_ucast_packets: 256767
     [15]: rx_ucast_packets: 0
     [15]: tx_ucast_packets: 185105
     rx_ucast_packets: 3507786
     tx_ucast_packets: 3508387

# ethtool -i eth1
driver: bnx2x
version: 1.60.00-1
firmware-version: bc 4.8.0 phy baa0.105
bus-info: 0000:02:00.1

02:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57711E
10Gigabit PCIe
	Subsystem: Hewlett-Packard Company NC532i Dual Port 10GbE Multifunction
BL-C Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 47
	Memory at fa000000 (64-bit, non-prefetchable) [size=8M]
	Memory at f9800000 (64-bit, non-prefetchable) [size=8M]
	[virtual] Expansion ROM at e7010000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=17 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number f4-ce-46-ff-fe-bb-32-d4
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel <?>
	Kernel driver in use: bnx2x
	Kernel modules: bnx2x


Any idea before a biscection ?

Thanks !


