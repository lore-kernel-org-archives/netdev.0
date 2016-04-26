From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 0/5] stmmac: dwmac-socfpga refactor+cleanup
Date: Tue, 26 Apr 2016 23:24:54 +0200
Message-ID: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35923 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbcDZVZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:25:26 -0400
Received: by mail-lf0-f67.google.com with SMTP id y84so4293385lfc.3
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 14:25:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aims to remove the init/exit callbacks from the dwmac-
socfpga driver and instead use standard PM callbacks. Doing this
will also allow us to cleanup the driver.

Eventually the init/exit callbacks will be deprecated and removed
from all drivers dwmac-* except for dwmac-generic. Drivers will be
refactored to use standard PM and remove callbacks.

This patch set should not change the behavior of the driver itself,
it only moves code around. The only exception to this is patch
number 4 which restores the resume callback behavior which was
changed in the "net: stmmac: socfpga: Remove re-registration of
reset controller" patch. I belive calling phy_resume() only
from the resume callback and not probe is the right thing to do.


Couple of heads-up here:
 1. This patch set depend on Marek's "Remove re-registration of
    reset controller" patch [1] which is not in net-next yet.
    Without that patch this set will not apply!

 2. The first patch changes the prototype of a couple of
    functions used in Alexandre's "add Ethernet glue logic for
    stm32 chip" patch [2] and will cause build failures for
    dwmac-stm32.c if not fixed up!
    If Alexandre's patch set is applied first I will gladly
    rebase my patch set to account for his driver as well.

So at the moment there are issues here :/

I guess one way of handing this would just be wait for all
the bits to come together in net-next and resend.

Dave: Please let me know if you have any preferred way of
      handling this.


[1] https://patchwork.ozlabs.org/patch/613085/
[2] https://patchwork.ozlabs.org/patch/614405/


Joachim Eastwood (5):
  stmmac: let remove/resume/suspend functions take device pointer
  stmmac: dwmac-socfpga: add PM ops and resume function
  stmmac: dwmac-socfpga: keep a copy of stmmac_rst in driver priv data
  stmmac: dwmac-socfpga: call phy_resume() only in resume callback
  stmmac: dwmac-socfpga: kill init() and rename setup() to set_phy_mode()

 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 106 +++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  15 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  24 +----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   6 +-
 5 files changed, 71 insertions(+), 86 deletions(-)

-- 
2.8.0
