From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v3 net-next 0/2] patchset: Support for configurable RSS hash key
Date: Fri, 28 Feb 2014 17:35:39 +0530
Message-ID: <2f27a7ef-29eb-4920-aac8-d80ca336d143@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:51587 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaB1MFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 07:05:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user would
want to change the hash key if he/she is not satisfied with the effectiveness
of the default hash-key in spreading the incoming flows evenly across the
RSS queues.

This patch set adds support for configuring the RSS hash-key via the
ethtool interface using -X option.

v3:
1. ETHTOOL_GRXFHINDIR, ETHTOOL_SRXFHINDIR command numbers & structure are
left unchanged.
2. Introduced new command numbers & structure for ETHTOOL_GRSSH & ETHTOOL_SRSSH.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  be2net: Support for configurable RSS hash key

 drivers/net/ethernet/emulex/benet/be.h         |   12 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  103 +++++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c    |   31 +++--
 include/linux/ethtool.h                        |   13 ++
 include/uapi/linux/ethtool.h                   |   30 ++++
 net/core/ethtool.c                             |  195 ++++++++++++++++++++++++
 8 files changed, 362 insertions(+), 31 deletions(-)
