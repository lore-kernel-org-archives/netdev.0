From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/7] nfp: expose more firmware and hw debug info
Date: Fri, 17 Feb 2017 14:00:20 -0800
Message-ID: <20170217220027.189992-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35134 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934415AbdBQWBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 17:01:05 -0500
Received: by mail-pf0-f182.google.com with SMTP id 68so5283187pfx.2
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 14:01:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series is mostly a result of flash firmware team requesting 
access to some of the information and data necessary for debugging 
firmware problems.  Patch 1 adds a missing error message.  Patch 2 
prints manufacturing info to logs in case PCI VPD capability is 
not programmed correctly.  Patches 3 and 4 allow reporting NSP ABI
version in ethtool -i.  Patch 5 allows dumping flash application 
logs.  

Patches 6 and 7 provides a way of application firmwares to declare 
limited SR-IOV support.  

Jakub Kicinski (7):
  nfp: refactor NSP initialization and add error message
  nfp: report manufacturing info on load
  nfp: store NSP ABI version in state structure
  nfp: report NSP ABI version in ethtool FW version
  nfp: add very basic access to NSP logs
  nfp: return nfp_rtsym_read_le() errors correctly
  nfp: allow application firmware to limit number of SR-IOV VFs

 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  85 ++++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   2 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   6 ++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 101 ++++++++++++++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |   1 +
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   4 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  37 +++++---
 .../net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c |   8 +-
 8 files changed, 204 insertions(+), 40 deletions(-)

-- 
2.11.0
