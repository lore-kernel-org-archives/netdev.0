From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Update
Date: Sun, 19 Jun 2011 17:58:21 -0700
Message-ID: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10991 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883Ab1FTA67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:58:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains update for e1000, igb, ixgbevf and ixgbe.

e1000 and igb: conversion to ndo_fix_features from Michal
ixgbevf: cleanup and 64 bit stats from Stephen
ixgbevf: Mainly cleanup of DCB code and the addition of Dell CEM suppor=
t.

Dropped the problem patch from Vasu that was previously submitted in th=
e last
patch series.

The following are changes since commit fd112f2e15ba85d387de446a81aeb11e=
46ecc55d:
  r8169: check firmware content sooner
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 mas=
ter

Emil Tantilov (1):
  ixgbe: add support for Dell CEM

Greg Rose (1):
  ixgbevf: Fix bungled declaration of ixgbevf_mbx_ops

John Fastabend (10):
  ixgbe: dcbnl reduce duplicated code and indentation
  ixgbe: consolidate packet buffer allocation
  ixgbe: consolidate MRQC and MTQC handling
  ixgbe: configure minimal packet buffers to support TC
  ixgbe: DCB use existing TX and RX queues
  ixgbe: DCB 82598 devices, tx_idx and rx_idx swapped
  ixgbe: setup redirection table for multiple packet buffers
  ixgbe: fix bit mask for DCB version
  ixgbe: DCB and perfect filters can coexist
  ixgbe: DCB, remove unneeded ixgbe_dcb_txq_to_tc() routine

Micha=C5=82 Miros=C5=82aw (2):
  e1000: convert to ndo_fix_features
  igb: convert to ndo_fix_features

Stephen Hemminger (2):
  ixgbevf: provide 64 bit statistics
  ixgbevf: remove unnecessary ampersands

Vasu Dev (1):
  ixgbe: setup per CPU PCI pool for FCoE DDP

 drivers/net/e1000/e1000_ethtool.c   |   69 ------
 drivers/net/e1000/e1000_main.c      |   30 +++-
 drivers/net/igb/igb_ethtool.c       |   67 ------
 drivers/net/igb/igb_main.c          |   33 +++-
 drivers/net/ixgbe/ixgbe.h           |    2 -
 drivers/net/ixgbe/ixgbe_82598.c     |   43 ++++
 drivers/net/ixgbe/ixgbe_82599.c     |   40 +----
 drivers/net/ixgbe/ixgbe_common.c    |  240 +++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h    |    5 +
 drivers/net/ixgbe/ixgbe_dcb.c       |   10 +-
 drivers/net/ixgbe/ixgbe_dcb.h       |    7 -
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   43 +----
 drivers/net/ixgbe/ixgbe_dcb_82598.h |    3 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |  119 +-----------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |   14 +--
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |   52 ++---
 drivers/net/ixgbe/ixgbe_fcoe.c      |  105 +++++++---
 drivers/net/ixgbe/ixgbe_fcoe.h      |   13 +-
 drivers/net/ixgbe/ixgbe_main.c      |  397 +++++++++++++++++----------=
--------
 drivers/net/ixgbe/ixgbe_type.h      |   71 +++++++
 drivers/net/ixgbe/ixgbe_x540.c      |    2 +
 drivers/net/ixgbevf/ixgbevf.h       |    8 +-
 drivers/net/ixgbevf/ixgbevf_main.c  |   57 ++++--
 23 files changed, 761 insertions(+), 669 deletions(-)

--=20
1.7.5.4

