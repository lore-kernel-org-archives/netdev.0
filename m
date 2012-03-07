From: <parav.pandit@emulex.com>
Subject: [RFC 0/2] be2net: Added functionality to support RoCE driver
Date: Wed, 7 Mar 2012 23:17:05 +0530
Message-ID: <102ec66a-5bd6-4e64-81b2-87ea6111e466@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parav.pandit@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:42843 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755979Ab2CGNhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 08:37:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav.pandit@emulex.com>

This patch is against roland's below Infiniband tree.
http://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git
Simiilar patch against netdev net-next tree will be made based on this patch.

This patch adds functionality to support RoCE (RDMA over Ethernet) driver.
- Detecting RoCE supported adapters and creating linked list of them.
- Enabling 5 more MSIX vectors for RoCE functionality.
- Calling registered callback functions of the RoCE driver
  whenever new RoCE capable device is added/removed.
- Notifying events to RoCE driver when interface is up or down.
- Provides device specific details to RoCE driver for each roce device.
- Provides low level mailbox command to be issued by RoCE driver
  before it can have it own MQ.

Parav Pandit (2):
  be2net: Added function to issue mailbox cmd on MQ.
  be2net: Added functionality to support RoCE driver

 drivers/net/ethernet/emulex/benet/Makefile  |    2 +-
 drivers/net/ethernet/emulex/benet/be.h      |   28 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   39 ++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 drivers/net/ethernet/emulex/benet/be_hw.h   |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   83 +++++++++++--
 drivers/net/ethernet/emulex/benet/be_roce.c |  185 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_roce.h |   75 +++++++++++
 8 files changed, 404 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/emulex/benet/be_roce.c
 create mode 100644 drivers/net/ethernet/emulex/benet/be_roce.h
