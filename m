From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: [PATCH] KS8851: Avoid NULL pointer in set rx mode
Date: Tue, 16 Mar 2010 16:24:54 -0600
Message-ID: <cb8016981003161524w6601d5e7i3885f77219582a0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f198.google.com ([209.85.216.198]:41904 "EHLO
	mail-px0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab0CPWYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 18:24:54 -0400
Received: by pxi36 with SMTP id 36so133348pxi.21
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 15:24:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel NULL pointer dereference when setting mode for IFF_MULTICAST.
Tested on SDP OMAP4430 board.

ks8851 spi1.0: message enable is 0
ks8851 spi1.0: revision 0, MAC f2:f4:2f:56:37:de, IRQ 194
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = c0004000
[00000000] *pgd=00000000
Internal error: Oops: 5 [#1] PREEMPT SMP
last sysfs file:
Modules linked in:
CPU: 0    Not tainted  (2.6.34-rc1-01039-g38d7ed1-dirty #3)
PC is at ks8851_set_rx_mode+0x88/0x124
LR is at bitrev32+0x24/0x2c

<snip>

Backtrace:
[<c01bfbd8>] ? (ks8851_set_rx_mode+0x0/0x124)
[<c01d4164>] (__dev_set_rx_mode+0x0/0x90)
[<c01dc460>] (dev_mc_add+0x0/0x78)
[<c021f0bc>] (igmp_group_added+0x0/0x64)
[<c021f174>] (ip_mc_inc_group+0x0/0x150)
[<c021f3b8>] (ip_mc_up+0x0/0x64)
[<c0219eb0>] (inetdev_event+0x0/0x3d4)
[<c0066818>] (notifier_call_chain+0x0/0x78)
[<c00668b8>] (__raw_notifier_call_chain+0x0/0x24)
[<c00668dc>] (raw_notifier_call_chain+0x0/0x28)
[<c01d7484>] (call_netdevice_notifiers+0x0/0x24)
[<c01d7780>] (__dev_notify_flags+0x0/0x68)
[<c01d77e8>] (dev_change_flags+0x0/0x4c)
[<c001f0bc>] (ip_auto_config+0x0/0xf1c)
[<c0028490>] (do_one_initcall+0x0/0x1bc)
 [<c00084dc>] (kernel_init+0x0/0x234)
Code: e15130bc e1833012 e14130bc e5943000 (e5934000)
---[ end trace ed0fb00a94142792 ]---
Kernel panic - not syncing: Fatal exception in interrupt

Signed-off-by: Abraham Arce <x0066660@ti.com>
---
 drivers/net/ks8851.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 0573e0b..13cc1ca 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -976,7 +976,6 @@ static void ks8851_set_rx_mode(struct net_device *dev)
 			crc >>= (32 - 6);  /* get top six bits */

 			rxctrl.mchash[crc >> 4] |= (1 << (crc & 0xf));
-			mcptr = mcptr->next;
 		}

 		rxctrl.rxcr1 = RXCR1_RXME | RXCR1_RXPAFMA;
-- 
1.5.4.3
