From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe Port cannot load, "failed to register GSI"
Date: Tue, 6 Dec 2016 15:22:58 -0800
Message-ID: <60fc28f5-9780-dc04-2721-043412d23d31@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:45028 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752475AbcLFX3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 18:29:24 -0500
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id EE9B040A79A
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 15:22:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We put 3 10-g dual-port ixgbe NICs and 4 4-port I350 NICs in a 2U rackmount, and one of the ixgbe ports
fails to come up.  This previously worked before reboot, so maybe it is a race somehow.  Kernel is 4.4.11+,
but not hacks to ixgbe or I350 drivers.

Anyone know if there is some sort of way to make this work reliably?

dmesg | grep ixgbe

[    5.803307] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.2.1-k
[    5.803309] ixgbe: Copyright (c) 1999-2015 Intel Corporation.
[    5.952119] ixgbe 0000:04:00.0: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[    5.952245] ixgbe 0000:04:00.0: PCI Express bandwidth of 32GT/s available
[    5.952246] ixgbe 0000:04:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[    5.952328] ixgbe 0000:04:00.0: MAC: 2, PHY: 15, SFP+: 5, PBA No: FFFFFF-0FF
[    5.952330] ixgbe 0000:04:00.0: 00:e0:ed:77:09:16
[    5.954004] ixgbe 0000:04:00.0: Intel(R) 10 Gigabit Network Connection
[    6.102346] ixgbe 0000:04:00.1: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[    6.102475] ixgbe 0000:04:00.1: PCI Express bandwidth of 32GT/s available
[    6.102478] ixgbe 0000:04:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[    6.102562] ixgbe 0000:04:00.1: MAC: 2, PHY: 15, SFP+: 6, PBA No: FFFFFF-0FF
[    6.102564] ixgbe 0000:04:00.1: 00:e0:ed:77:09:17
[    6.104869] ixgbe 0000:04:00.1: Intel(R) 10 Gigabit Network Connection
[    6.253429] ixgbe 0000:05:00.0: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[    6.253558] ixgbe 0000:05:00.0: PCI Express bandwidth of 32GT/s available
[    6.253560] ixgbe 0000:05:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[    6.253644] ixgbe 0000:05:00.0: MAC: 2, PHY: 15, SFP+: 5, PBA No: FFFFFF-0FF
[    6.253646] ixgbe 0000:05:00.0: 00:e0:ed:79:06:50
[    6.255855] ixgbe 0000:05:00.0: Intel(R) 10 Gigabit Network Connection
[    6.404128] ixgbe 0000:05:00.1: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[    6.404254] ixgbe 0000:05:00.1: PCI Express bandwidth of 32GT/s available
[    6.404255] ixgbe 0000:05:00.1: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[    6.404337] ixgbe 0000:05:00.1: MAC: 2, PHY: 15, SFP+: 6, PBA No: FFFFFF-0FF
[    6.404339] ixgbe 0000:05:00.1: 00:e0:ed:79:06:51
[    6.405914] ixgbe 0000:05:00.1: Intel(R) 10 Gigabit Network Connection
[    6.554373] ixgbe 0000:06:00.0: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
[    6.554501] ixgbe 0000:06:00.0: PCI Express bandwidth of 32GT/s available
[    6.554504] ixgbe 0000:06:00.0: (Speed:5.0GT/s, Width: x8, Encoding Loss:20%)
[    6.554588] ixgbe 0000:06:00.0: MAC: 2, PHY: 15, SFP+: 5, PBA No: FFFFFF-0FF
[    6.554590] ixgbe 0000:06:00.0: 00:e0:ed:79:06:56
[    6.556994] ixgbe 0000:06:00.0: Intel(R) 10 Gigabit Network Connection
[    6.557160] ixgbe 0000:06:00.1: PCI INT B: failed to register GSI
[    6.557169] ixgbe: probe of 0000:06:00.1 failed with error -28

Thanks,
Ben
-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
