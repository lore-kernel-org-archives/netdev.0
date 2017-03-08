From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/9] nfp: CRC32 RSS hash, port name reporting and misc fastpath cleanups
Date: Wed,  8 Mar 2017 08:56:59 -0800
Message-ID: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36002 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752501AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pg0-f50.google.com with SMTP id 187so15169330pgb.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds support for CRC32 RSS hash function to kernel API
of which NFP driver immediately makes use.  There is also a
.ndo_get_phys_port_name() implementation conforming to switchdev 
name format.  Small patch takes advantage of napi_complete_done()'s
return code.  Simon provides a fix for potentially trusting values 
returned from FW too much.

A handful of unassuming fast path adjustments is also thrown in to make
the upcoming xdp_adjust_head() series easier to review.

Jakub Kicinski (8):
  ethtool: add CRC32 as an RSS hash function
  nfp: add support for reporting CRC32 hash function
  nfp: implement .ndo_get_phys_port_name()
  nfp: move more ring debug info to debugfs
  nfp: reorder variables in nfp_net_tx()
  nfp: store device pointer for the fastpath
  nfp: avoid rearming the interrupts when in busy poll
  nfp: add metadata format bit

Simon Horman (1):
  nfp: prevent theoretical buffer overrun in nfp_eth_read_ports

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  15 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 141 ++++++++++++++-------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  14 +-
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  13 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  23 +++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |   7 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |   7 +-
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   |  65 +++++++---
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.h   |  15 ++-
 include/linux/ethtool.h                            |   2 +
 net/core/ethtool.c                                 |   1 +
 11 files changed, 216 insertions(+), 87 deletions(-)

-- 
2.11.0
