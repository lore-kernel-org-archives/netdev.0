From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/14] bnxt_en: Updates for net-next.
Date: Thu, 26 Oct 2017 11:51:18 -0400
Message-ID: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:52345 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932255AbdJZPvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:46 -0400
Received: by mail-qt0-f174.google.com with SMTP id 31so4856633qtz.9
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series includes firmware interface update, some optimizations,
some new PCI IDs, new MTU checks, ethtool reset method, interrupt coalescing
code cleanup, and TC flower offload for vxlan encap/decap from Sathya
Perla.


Michael Chan (7):
  bnxt_en: Update firmware interface to 1.8.3.1
  bnxt_en: Check for zero length value in bnxt_get_nvram_item().
  bnxt_en: Get firmware package version one time.
  bnxt_en: Optimize .ndo_set_mac_address() for VFs.
  bnxt_en: Check maximum supported MTU from firmware.
  bnxt_en: Reorganize the coalescing parameters.
  bnxt_en: Refactor and simplify coalescing code.

Ray Jui (1):
  bnxt_en: Add PCIe device ID for bcm58804

Rob Miller (1):
  bnxt_en: adding PCI ID for SMARTNIC VF support

Sathya Perla (4):
  bnxt_en: add support for Flower based vxlan encap/decap offload
  bnxt_en: add hwrm FW cmds for cfa_encap_record and decap_filter
  bnxt_en: query cfa flow stats periodically to compute 'lastused'
    attribute
  bnxt_en: alloc tc_info{} struct only when tc flower is enabled

Vasundhara Volam (1):
  bnxt_en: Add ethtool reset method

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 170 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  49 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 120 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |   2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 420 +++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c      | 932 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h      |  88 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     |   3 +
 9 files changed, 1558 insertions(+), 228 deletions(-)

-- 
1.8.3.1
