From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v2 net-next 0/2] patchset - Support for configurable RSS hash key
Date: Sat, 22 Feb 2014 17:21:56 +0530
Message-ID: <2c88a5a4-fec1-40df-a0f9-f128fda3ed82@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21350 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbaBVLvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 06:51:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value for the RSS hash key. Irrespective of the type of the key used, the user would want to change the hash key if he/she is not satisfied with the effectiveness of the default hash-key in spreading the incoming flows evenly across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool interface using .X/-x option.

The patch set consists of user space ethtool patches. Kernel changes are submitted as a separate patch set.

v2 changes:
1. Integrated hash-key configuration with indirection table configuration and renamed ethtool_get_rxfh_indir to ethtool_get_rxfh and  ethtool_set_rxfh_indir to ethtool_set_rxfh.
2. Renamed ethtool_rxfh_indir structure to ethtool_rxfh. This new structure will accommodate for both Rx flow hash indirection table and key.
3. Hash key is made variable length.
4. Changes will enable user to set indirection table alone, hash key alone and both as well.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  ethtool: Support for configurable RSS hash key

 drivers/net/ethernet/emulex/benet/be.h         |   12 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  103 +++++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c    |   31 +++--
 include/linux/ethtool.h                        |   17 ++-
 include/uapi/linux/ethtool.h                   |   38 +++--
 net/core/ethtool.c                             |  207 ++++++++++++++++--------
 8 files changed, 302 insertions(+), 115 deletions(-)
