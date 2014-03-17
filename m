From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS hash key
Date: Mon, 17 Mar 2014 18:01:33 +0530
Message-ID: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:16944 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932767AbaCQMcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:32:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value for
the RSS hash key. Irrespective of the type of the key used, the user would want
to change the hash key if he/she is not satisfied with the effectiveness of the
default hash-key in spreading the incoming flows evenly across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool
interface using -X option.

v5:
1. Removed "inline" keyword for ethtool_copy_validate_indir function.
2. Added description about what "indir_size == 0xDEADBEEF" means.

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
