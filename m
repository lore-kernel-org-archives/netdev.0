From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 0/7] Add Chelsio T4 firmware configuration file support
Date: Wed, 26 Sep 2012 18:09:35 +0530
Message-ID: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com, felix@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17106 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab2IZMnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David Miller,

This patch series adds aupport for firmware configuration file for Chelsio T4
adapters.

The Firmware Configuration file was primarily developed in order to centralize
all of the configuration, resource allocation, etc. for Unified Wire operation
where multiple Physical / Virtual Function Drivers would be using a T4 adapter
simultaneously.

The patch series also has bug fixes which can occur while upgrading the T4
firmware.

The patch series is built against David Miller's net-next tree.

Thanks,
Vipul Pandya

Vipul Pandya (7):
  cxgb4: Fix incorrect values for MEMWIN*_APERTURE and MEMWIN*_BASE
  cxgb4: Add functions to read memory via PCIE memory window
  cxgb4/cxgb4vf: Code cleanup to enable T4 Configuration File support
  cxgb4: Add support for T4 configuration file
  cxgb4: Add support for T4 hardwired configuration settings
  cxgb4: Inform caller if driver didn't upgrade firmware
  cxgb4: Don't attempt to upgrade T4 firmware when cxgb4 will end up as
    a slave

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   51 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  936 ++++++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    2 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  337 +++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  722 +++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |   80 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  131 +++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   97 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |    5 +-
 9 files changed, 2139 insertions(+), 222 deletions(-)
