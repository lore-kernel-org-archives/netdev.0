From: <parav.pandit@emulex.com>
Subject: [RFC V1 0/2] be2net: Added functionality to support RoCE driver
Date: Sun, 11 Mar 2012 16:19:28 +0530
Message-ID: <192f3094-0c31-43b1-892d-aebfbcec5083@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parav.pandit@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:34474 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751147Ab2CKGkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 01:40:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav.pandit@emulex.com>

This patch addresses all the review comments given by Francois Romieu &
David Laight for past patch except be_roce_supported() macro as it
breaks the modularity of be_cmds.x

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
 drivers/net/ethernet/emulex/benet/be.h      |   38 ++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   39 ++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 drivers/net/ethernet/emulex/benet/be_hw.h   |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   83 ++++++++++--
 drivers/net/ethernet/emulex/benet/be_roce.c |  183 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_roce.h |   75 +++++++++++
 8 files changed, 409 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/emulex/benet/be_roce.c
 create mode 100644 drivers/net/ethernet/emulex/benet/be_roce.h
