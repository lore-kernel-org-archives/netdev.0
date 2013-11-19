From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Tue, 19 Nov 2013 07:40:51 -0800
Message-ID: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11437 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510Ab3KSPk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 10:40:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to net and igb.

John provides a patch against net to be able to walk all upper devices
when bringing a device online where the RTNL lock is held.

Akeem provides a igb fix where WOL was being reported as supported on
some ethernet devices which did not have that capability.

Carolyn provides a igb fix to add a call to dev_close if the queue
reinit fails in order to make it clear to the user that the device is
down.

The following are changes since commit d11a347de3f521af62da25e74156ea39e3774f19:
  be2net: Delete secondary unicast MAC addresses during be_close
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Akeem G Abodunrin (1):
  igb: Fixed Wake On Lan support

Carolyn Wyborny (1):
  igb: Update queue reinit function to call dev_close when init of
    queues fails

John Fastabend (1):
  net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock held

 drivers/net/ethernet/intel/igb/igb_ethtool.c  |  7 +++--
 drivers/net/ethernet/intel/igb/igb_main.c     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  6 ++--
 include/linux/netdevice.h                     |  9 ++++++
 net/core/dev.c                                | 43 ++++++++++++++++++++-------
 5 files changed, 49 insertions(+), 17 deletions(-)

-- 
1.8.3.1
