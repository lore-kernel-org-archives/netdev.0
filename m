From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/2 v3] net: qcom/emac: simplify support for different SOCs
Date: Thu,  8 Dec 2016 13:24:19 -0600
Message-ID: <1481225061-30962-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42252 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752715AbcLHTYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:24:25 -0500
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
  [v2] net: qcom/emac: move phy init code to separate files
  [v3] net: qcom/emac: add support for the Qualcomm Technologies QDF2400

 drivers/net/ethernet/qualcomm/emac/Makefile        |   4 +-
 .../ethernet/qualcomm/emac/emac-sgmii-fsm9900.c    | 245 +++++++++
 .../ethernet/qualcomm/emac/emac-sgmii-qdf2400.c    | 217 ++++++++
 .../ethernet/qualcomm/emac/emac-sgmii-qdf2432.c    | 210 ++++++++
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    | 569 ++-------------------
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   6 +-
 6 files changed, 725 insertions(+), 526 deletions(-)
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
