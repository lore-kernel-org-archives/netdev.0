From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v3 8/9] forcedeth: stats updated with a deferrable timer
Date: Mon, 14 Nov 2011 16:11:18 -0800
Message-ID: <6a56ea00fc2319ead99aebbd6cbcbb10114dfda1.1321313729.git.david.decotigny@google.com>
References: <cover.1321313729.git.david.decotigny@google.com>
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
Received: from mail-wy0-f202.google.com ([74.125.82.202]:59965 "EHLO
	mail-wy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756832Ab1KOALv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 19:11:51 -0500
Received: by wye20 with SMTP id 20so104359wye.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 16:11:49 -0800 (PST)
In-Reply-To: <cover.1321313729.git.david.decotigny@google.com>
In-Reply-To: <cover.1321313729.git.david.decotigny@google.com>
References: <cover.1321313729.git.david.decotigny@google.com>
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
index dd24035..50133f1 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5540,7 +5540,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	init_timer(&np->nic_poll);
 	np->nic_poll.data = (unsigned long) dev;
 	np->nic_poll.function = nv_do_nic_poll;	/* timer handler */
-	init_timer(&np->stats_poll);
+	init_timer_deferrable(&np->stats_poll);
 	np->stats_poll.data = (unsigned long) dev;
 	np->stats_poll.function = nv_do_stats_poll;	/* timer handler */
 
-- 
1.7.3.1
