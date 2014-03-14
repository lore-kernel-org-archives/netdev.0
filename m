From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v4 net-next 0/2] patchset: Support for configurable RSS hash key
Date: Fri, 14 Mar 2014 16:24:42 +0530
Message-ID: <2e763efd-a82f-44f5-bd7c-4bb13b7c15ec@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:5134 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbaCNKyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 06:54:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value for
the RSS hash key. Irrespective of the type of the key used, the user would want
to change the hash key if he/she is not satisfied with the effectiveness of the
default hash-key in spreading the incoming flows evenly across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool
interface using -X option.

v4:
Addressed Ben's comments.

1. Edited ethtool_rxfh command description to fit into one physical line.
2. Edited rss_config description to explain how indirection table and hashkey
   are arranged in memory.
3. Corrected the conditions in ethtool_get_rxfh & ethtool_set_rxfh routines
   for EOPNOTSUPP error case.
4, Corrected the size to be allocated for rss configuration to include size of
   struct ethtool_rxfh.
5. Had put common functionality of ethtool_set_rxfh & ethtool_set_rxfh_indir
   into ethtool_copy_validate_indir routine.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key.
  be2net: Support for configurable RSS hash key.

 drivers/net/ethernet/emulex/benet/be.h         |   12 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  103 ++++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c    |   31 ++--
 include/linux/ethtool.h                        |   13 ++
 include/uapi/linux/ethtool.h                   |   29 +++
 net/core/ethtool.c                             |  219 ++++++++++++++++++++++--
 8 files changed, 371 insertions(+), 45 deletions(-)
