From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 00/10] Workarounds and fixes for ntuple filters
Date: Fri, 25 Feb 2011 15:32:39 -0800
Message-ID: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24276 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756078Ab1BYXck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:32:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to address issue in the implementation of ntuple
filters in both ixgbe and the kernel.  The main issue being that ntuple
filters didn't support the ability for drivers to retain and display
filters.

This series addresses it by removing the ETHTOOL_GRXNTUPLE interface
from the kernel and extends the ethtool network flow classifier interface
to handle the same fields that ntuple filters provide.  I have a separate
set of patches I will be emailing out in the next few minutes that will
contain the ethtool user-space portion of these changes.
 
The patches labeled with RFC are currently just for comments as I am not
submitting them directly to the netdev tree and will be instead submitting
them to the Jeff Kirsher's Intel network driver tree for submission.

---

Alexander Duyck (10):
      [RFC] ixgbe: Add support for using the same fields as ntuple in nfc
      [RFC] ixgbe: add support for nfc addition and removal of filters
      [RFC] ixgbe: add support for displaying ntuple filters via the nfc interface
      [RFC] ixgbe: add basic support for settting and getting nfc controls
      [RFC] ixgbe: update perfect filter framework to support retaining filters
      [RFC] ixgbe: add support for different Rx packet buffer sizes
      [RFC] ethtool: remove support for ETHTOOL_GRXNTUPLE
      [RFC] ixgbe: remove ntuple filtering
      ethtool: add ntuple flow specifier to network flow classifier
      ethtool: prevent null pointer dereference with NTUPLE set but no set_rx_ntuple


 drivers/net/ixgbe/ixgbe.h         |   29 +-
 drivers/net/ixgbe/ixgbe_82598.c   |    2 
 drivers/net/ixgbe/ixgbe_82599.c   |  661 ++++++++++++++++++++-----------------
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |   47 +--
 drivers/net/ixgbe/ixgbe_ethtool.c |  504 ++++++++++++++++++++++------
 drivers/net/ixgbe/ixgbe_main.c    |   90 +++--
 drivers/net/ixgbe/ixgbe_type.h    |   25 +
 drivers/net/ixgbe/ixgbe_x540.c    |    2 
 include/linux/ethtool.h           |   27 +-
 include/linux/netdevice.h         |    3 
 net/core/dev.c                    |    5 
 net/core/ethtool.c                |  302 -----------------
 12 files changed, 884 insertions(+), 813 deletions(-)

-- 
