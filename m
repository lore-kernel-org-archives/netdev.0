From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 0/2] ethtool: {SG}RXFH indirection deficiency
Date: Fri,  5 Feb 2016 12:30:19 -0800
Message-ID: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22173 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755924AbcBEUad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 15:30:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a new ethtool operation .reset_rxfh_indir which is
used by the core ethtool stack to properly indicate to a driver that
the default RSS indirection table has been requested. Current behavior
for notifying the default settings is indistinguishable from an
explicit request. There is no easy way to look at the indirection
table and tell if it matches the default, either. To allow drivers the
ability to correctly report -EINVAL when changing the number of
channels, add the new operation suggested. I chose to use a new
ethtool op instead of an additional flag since this has a lower impact
and we already use NULL on the *indir variable in set_rxfh to indicate
no change was requested.

The second patch in the series is an example implementation of the
.reset_rxfh_indir operation along with fixes to the fm10k_set_channels
to prevent changing the number of channels if it would interfere
with the current redirection table.

Jacob Keller (2):
  ethtool: support notifying drivers when user requests default rxfh
    table
  fm10k: correctly report error when changing number of channels

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 45 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 11 ++++--
 include/linux/ethtool.h                          |  3 ++
 net/core/ethtool.c                               |  8 +++++
 5 files changed, 66 insertions(+), 3 deletions(-)

-- 
2.7.0.236.gda096a0.dirty
