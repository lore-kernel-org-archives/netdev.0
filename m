From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v4 8/8] forcedeth: stats updated with a deferrable timer
Date: Tue, 15 Nov 2011 11:25:41 -0800
Message-ID: <ba205b5e371d4bb8a8f765ee663597238679c650.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f74.google.com ([209.85.161.74]:61803 "EHLO
	mail-fx0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757320Ab1KOT0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 14:26:08 -0500
Received: by faap16 with SMTP id p16so21188faa.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 11:26:06 -0800 (PST)
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark stats timer as deferrable: punctuality in waking the stats timer
callback doesn't matter much, as it is responsible only to avoid
integer wraparound.

We need at least 1 other timer to fire within 17s (fully loaded 1Gbps)
to avoid wrap-arounds. Desired period is still 10s.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 7284f40..b5c85de 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5538,7 +5538,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	init_timer(&np->nic_poll);
 	np->nic_poll.data = (unsigned long) dev;
 	np->nic_poll.function = nv_do_nic_poll;	/* timer handler */
-	init_timer(&np->stats_poll);
+	init_timer_deferrable(&np->stats_poll);
 	np->stats_poll.data = (unsigned long) dev;
 	np->stats_poll.function = nv_do_stats_poll;	/* timer handler */
 
-- 
1.7.3.1
