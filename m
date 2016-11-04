From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next v2 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Fri,  4 Nov 2016 18:54:04 +0100
Message-ID: <20161104175411.12943-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33165 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934776AbcKDRzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:55:24 -0400
Received: by mail-lf0-f68.google.com with SMTP id 98so1681073lfs.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 10:55:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set aims to remove the init/exit callbacks from the 
dwmac-sti driver and instead use standard PM callbacks. Doing this
will also allow us to cleanup the driver.

Eventually the init/exit callbacks will be deprecated and removed
from all drivers dwmac-* except for dwmac-generic. Drivers will be
refactored to use standard PM and remove callbacks.

Changes since v2:
 - add missing static to sti_dwmac_pm_ops
 - s/sti_dwmac_set_phy_mode/sti_dwmac_set_mode
 - acked/tested by Giuseppe

Joachim Eastwood (7):
  stmmac: dwmac-sti: remove useless of_node check
  stmmac: dwmac-sti: remove clk NULL checks
  stmmac: dwmac-sti: add PM ops and resume function
  stmmac: dwmac-sti: move st,gmac_en parsing to sti_dwmac_parse_data
  stmmac: dwmac-sti: move clk_prepare_enable out of init and add error handling
  stmmac: dwmac-sti: clean up and rename sti_dwmac_init
  stmmac: dwmac-sti: remove unused priv dev member

 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 87 ++++++++++++++++---------
 1 file changed, 58 insertions(+), 29 deletions(-)

-- 
2.10.2
