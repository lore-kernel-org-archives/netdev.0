From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: RX performance bottleneck on i.MX6Q with KSZ9031
Date: Wed, 18 Feb 2015 13:25:08 +0100
Message-ID: <20150218122507.GA6651@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pqgruber.com ([178.189.19.235]:38108 "EHLO
	mail.pqgruber.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbBRMd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 07:33:58 -0500
Received: from pqgruber.com (chello213047168109.15.14.vie.surfer.at [213.47.168.109])
	by mail.pqgruber.com (Postfix) with ESMTPSA id 8DADB13990
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 13:25:09 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we are developing an IO board with a TQMa6Q module, which in turn is
using the i.MX6Q. As ethernet PHY we are using the Micrel KSZ9031RNX.
We run Linux 3.19 and are experiencing poor receive throughput when
testing with iperf. However, this also occured on 3.16 and before.

Transmit performance is OK (about 350-400 Mbit/s), but when receiving
data, there seems to be an upper bound of 135 Mbit/s.

I am aware of the Freescale ERR004512, which explains the bottleneck for
TX but not for RX. I am of course testing this separately.

What's also odd is that when I am pinging the embedded board from my
Linux Desktop, I get the following result:
35 packets transmitted, 35 received, 0% packet loss, time 34043ms
rtt min/avg/max/mdev = 0.467/38.600/79.556/23.740 ms
But when pinging my desktop from the embedded board, I get a much lower RTT:
35 packets transmitted, 35 packets received, 0% packet loss
round-trip min/avg/max = 0.216/0.283/0.336 ms

ethtool eth0 reports the following:
Supported ports: [ TP MII ]
Supported link modes:   10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full 1000baseT/Full
Supported pause frame use: Symmetric
Supports auto-negotiation: Yes
Advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full 1000baseT/Full
Advertised pause frame use: Symmetric
Advertised auto-negotiation: Yes
Link partner advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full 1000baseT/Full
Link partner advertised pause frame use: No
Link partner advertised auto-negotiation: Yes
Speed: 1000Mb/s
Duplex: Full
Port: MII
PHYAD: 3
Transceiver: external
Auto-negotiation: on
Link detected: yes

Can anyone confirm poor ethernet RX performance when using the i.MX6
processor and/or the KSZ9031RNX PHY?
Any ideas what the cause or bottleneck might be? fec driver, phy, mac?

Do you have any tips on how to debug this further and improve the
performance?

Best regards,
Clemens
