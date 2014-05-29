From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 0/2] Provide common means for device address sync
Date: Wed, 28 May 2014 18:44:41 -0700
Message-ID: <20140529013440.21464.2499.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: ssujith@cisco.com, neepatel@cisco.com, davem@davemloft.net,
	_govind@gmx.com, benve@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46550 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262AbaE2Bop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 21:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements a means for synchronizing both unicast and
multicast addresses on a device interface.  The code is based on the original
implementation of dev_uc_sync that was available for syncing a VLAN to the
lower dev.

The original reason for coming up for this patch is a driver that is still in
the early stages of development.  The nearest driver I could find that
appeared to have the same limitations as the driver I was working on was the
Cisco enic driver.  For this reason I chose it as the first driver to make use
of this interface publicly.

However, I do not have a Cisco enic interface so I have only been able to
compile test any changes made to the driver.  I tried to keep this change as
simple as possible to avoid any issues.  Any help with testing would be
greatly appreciated.

---

Alexander Duyck (2):
      net: Add support for device specific address syncing
      enic: Update driver to use __dev_uc/mc_sync/unsync calls


 drivers/net/ethernet/cisco/enic/enic.h      |    2 
 drivers/net/ethernet/cisco/enic/enic_dev.c  |    4 -
 drivers/net/ethernet/cisco/enic/enic_dev.h  |    4 -
 drivers/net/ethernet/cisco/enic/enic_main.c |  173 ++++++++++-----------------
 drivers/net/ethernet/cisco/enic/vnic_dev.c  |    4 -
 drivers/net/ethernet/cisco/enic/vnic_dev.h  |    4 -
 include/linux/netdevice.h                   |   73 +++++++++++
 net/core/dev_addr_lists.c                   |   85 +++++++++++++
 8 files changed, 231 insertions(+), 118 deletions(-)

--
