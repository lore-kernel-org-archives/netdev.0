From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/3] [v2] Add basic ACPI support to the Qualcomm Technologies EMAC driver
Date: Wed, 28 Sep 2016 11:58:41 -0500
Message-ID: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, linaro-acpi@lists.linaro.org,
        linux-arm-kernel@lists.infradead.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53586 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932797AbcI1Q6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 12:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support to the EMAC driver for extracting addresses,
interrupts, and some _DSDs (properties) from ACPI.  The first two patches
clean up the code, and the third patch adds ACPI-specific functionality.

The first patch fixes a bug with handling the platform_device for the
internal PHY.  This phy is treated as a separate device in both DT and
ACPI, but since the platform is not released automatically when the 
driver unloads, managed functions like devm_ioremap_resource cannot be
used. 

The second patch replaces of_get_mac_address with its platform-independent
equivalent device_get_mac_address.  

The third patch parses the ACPI tables to obtain the platform_device for
the primary EMAC node ("QCOM8070") and the internal phy node ("QCOM8071").

Timur Tabi (3):
  [v2] net: qcom/emac: do not use devm on internal phy pdev
  [v2] net: qcom/emac: use device_get_mac_address
  [v2] net: qcom/emac: initial ACPI support

 drivers/net/ethernet/qualcomm/emac/emac-phy.c   |  37 ++++++--
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 110 ++++++++++++++++++------
 drivers/net/ethernet/qualcomm/emac/emac.c       |  26 ++++--
 3 files changed, 134 insertions(+), 39 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
