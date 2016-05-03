From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/5] net: remove trans_start from struct net_device
Date: Tue,  3 May 2016 16:30:57 +0200
Message-ID: <1462285862-30946-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently have two instances for trans_start, once in
net_device and once in netdev_queue.

This series removes trans_start from net_device.
Updates to dev->trans_start are replaced with updates to netdev queue 0.

This series is compile-tested only.
Replacement is done in 3 steps:

1. Replace read-accesses:
  x = dev->trans_start

  gets replaced by
  x = dev_trans_start(dev)

2. Replace write accesses:
  dev->trans_start = jiffies;

  gets replaced with new helper:
  netif_trans_update(dev);

3. This helper is then changed to set
   netdev_get_tx_queue(dev, 0)->trans_start
   instead of dev->trans_start.

After this dev->trans_start can be removed.

It should be noted that after this series several instances
of netif_trans_update() are useless (if they occur in
.ndo_start_xmit and driver doesn't set LLTX flag -- stack already
did an update).

Comments welcome.
