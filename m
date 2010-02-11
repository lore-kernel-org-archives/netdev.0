From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v5 0/3] Introduce n-tuple ethtool support
Date: Wed, 10 Feb 2010 18:07:18 -0800
Message-ID: <20100211020310.23436.85885.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:35357 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755101Ab0BKCHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 21:07:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more round of fixes, based on feedback from Patrick McHardy

1) Change the list count to an unsigned value
2) Fix a memory leak
3) Removed an unnecessary list traversal in the ethtool core
4) Moved all list destruction to a helper function, allowing the driver
to control when it clears the list (aside from when free_netdev() kills
the cached list).

---

Peter Waskiewicz (3):
      ixgbe: Bump driver version up
      ixgbe: Add support for the new ethtool n-tuple programming interface
      ethtool: Introduce n-tuple filter programming support


 drivers/net/ixgbe/ixgbe.h         |    4 
 drivers/net/ixgbe/ixgbe_82599.c   |  106 ++++++++++--
 drivers/net/ixgbe/ixgbe_ethtool.c |  111 ++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |   18 ++
 drivers/net/ixgbe/ixgbe_type.h    |    9 +
 include/linux/ethtool.h           |   50 ++++++
 include/linux/netdevice.h         |    3 
 net/core/dev.c                    |    6 +
 net/core/ethtool.c                |  332 +++++++++++++++++++++++++++++++++++++
 9 files changed, 619 insertions(+), 20 deletions(-)

-- 
Cheers,
Jeff
