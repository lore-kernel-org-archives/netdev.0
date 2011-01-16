From: Simon Arlott <simon@fire.lp0.eu>
Subject: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Sun, 16 Jan 2011 14:09:32 +0000
Message-ID: <4D32FC1C.3010905@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com
To: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:50586 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165Ab1APOQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jan 2011 09:16:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[    1.666706] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 16, addr 00:e0:81:4d:2b:ec
[    1.666767] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gbit lnktim msi desc-v3

I have eth0 and eth0.3840 which works until I add eth0 to a bridge.
While eth0 is in a bridge (the bridge device is up), eth0.3840 is unable
to receive packets. Using tcpdump on eth0 shows the packets being
received with a VLAN tag but they don't appear on eth0.3840. They appear
with the VLAN tag on the bridge interface.

If I remove eth0 from the bridge, eth0.3840 starts working again. It
still works if eth0.3840 is part of a bridge but eth0 isn't (the device
is in promiscuous mode). I've only tested with broadcast traffic.

This works with 2.6.36.

git bisect produces 3701e51382a026cba10c60b03efabe534fba4ca4 as the
first bad commit.

The behaviour of drivers/net/forcedeth.c nv_rx_process_optimized looks
ok - vlan_gro_receive and napi_gro_receive are called correctly. (The
likely(!np->vlangrp) looks odd as it'll always be false if vlans are in
use).

-- 
Simon Arlott
