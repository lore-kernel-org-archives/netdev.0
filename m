From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v6 net-next 0/2] patchset: Support for configurable RSS hash key
Date: Mon, 21 Apr 2014 15:37:58 +0530
Message-ID: <768840ed-ec8a-444b-82d5-8715d2e19638@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:16867 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaDUKIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 06:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user would
want to change the hash key if he/she is not satisfied with the effectiveness
of the default hash-key in spreading the incoming flows evenly across the
RSS queues.

This patch set adds support for configuring the RSS hash-key via the
ethtool interface using -X option.

v6:
1. Changed ethtool core to pass seperate pointers of indirection and hash key
   to the driver.
2. Added rss_context field to ethtool_rxfh structure to support multiple
   rss contexts.



Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key.
  be2net: Support for configurable RSS hash key.

 drivers/net/ethernet/emulex/benet/be.h         |   12 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   92 +++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c    |   31 ++--
 include/linux/ethtool.h                        |   13 ++
 include/uapi/linux/ethtool.h                   |   32 ++++
 net/core/ethtool.c                             |  221 ++++++++++++++++++++++--
 8 files changed, 365 insertions(+), 45 deletions(-)
