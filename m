From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/2] net: qcom/emac: simplify support for different SOCs
Date: Mon, 21 Nov 2016 16:58:20 -0600
Message-ID: <1479769102-27909-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, alokc@codeaurora.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55798 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753981AbcKUW6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 17:58:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On SOCs that have the Qualcomm EMAC network controller, the internal
PHY block is always different.  Sometimes the differences are small, 
sometimes it might be a completely different IP.  Either way, using version
numbers to differentiate them and putting all of the init code in one
file does not scale.

This patchset does two things:  The first breaks up the current code into
different files, and the second patch adds support for a third SOC, the
Qualcomm Technologies QDF2400 ARM Server SOC.

Timur Tabi (2):
  net: qcom/emac: move phy init code to separate files
  net: qcom/emac: add support for the Qualcomm Technologies QDF2400

 drivers/net/ethernet/qualcomm/emac/Makefile        |   4 +-
 .../ethernet/qualcomm/emac/emac-sgmii-fsm9900.c    | 246 ++++++++++
 .../ethernet/qualcomm/emac/emac-sgmii-qdf2400.c    | 217 +++++++++
 .../ethernet/qualcomm/emac/emac-sgmii-qdf2432.c    | 210 ++++++++
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    | 542 +--------------------
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   6 +-
 6 files changed, 702 insertions(+), 523 deletions(-)
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
