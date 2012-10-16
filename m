From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/6] Add CPTS PTP driver support
Date: Wed, 17 Oct 2012 04:15:12 +0530
Message-ID: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Richard Cochran <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:53361 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578Ab2JPWpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 18:45:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains driver implementation for TI Common Platform
Time Sync (CPTS) driver for PTP packet timestamping.

CPTS is found in following TI SoC.
* AM335X - http://www.ti.com/litv/pdf/spruh73c
* DM814X - http://www.ti.com/litv/pdf/sprugz8

The Common Platform Time Sync (CPTS) module is used to facilitate host
control of time sync operations. It enables compliance with the IEEE 1588-2008
standard for a precision clock synchronization protocol

This patch series is tested over vanilla kernel with the below patches
http://marc.info/?l=linux-arm-kernel&m=135032863723906&w=2
Tested both L2 and L4 PTP packet timestamping

Mugunthan V N (6):
  drivers: net: ethernet: cpsw: add support for CPSW register offset
    changes in different IP version
  drivers: net: ethernet: davinci_cpdma: add clear api for statistics
    interrupt
  drivers: net: ethernet: cpsw: add multicast address to ALE table
  ptp: add api to get ptp seq id and event type from skb
  drivers: net: ethernet: cpts: implement cpts hardware clock
  drivers: net: ethernet: cpsw: implement timestamping capabilities in
    cpsw

 Documentation/devicetree/bindings/net/cpsw.txt |    3 +
 drivers/net/ethernet/ti/Kconfig                |   10 +
 drivers/net/ethernet/ti/Makefile               |    2 +-
 drivers/net/ethernet/ti/cpsw.c                 |  409 ++++++++++++++++++++++--
 drivers/net/ethernet/ti/cpsw_ale.c             |   31 ++-
 drivers/net/ethernet/ti/cpsw_ale.h             |    1 +
 drivers/net/ethernet/ti/cpts.c                 |  399 +++++++++++++++++++++++
 drivers/net/ethernet/ti/cpts.h                 |  118 +++++++
 drivers/net/ethernet/ti/davinci_cpdma.c        |    8 +
 drivers/net/ethernet/ti/davinci_cpdma.h        |    1 +
 include/linux/platform_data/cpsw.h             |    1 +
 include/linux/ptp_classify.h                   |   42 +++
 12 files changed, 991 insertions(+), 34 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpts.c
 create mode 100644 drivers/net/ethernet/ti/cpts.h
