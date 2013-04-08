From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/5] stmmac code tidy-up (v2)
Date: Mon,  8 Apr 2013 14:09:58 +0200
Message-ID: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shiraz.hashim@st.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:60242 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935225Ab3DHMKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 08:10:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches review and tidy-up the driver to respect the codying-style rules
where there were some problems.
Also now kernel-doc passes w/o any warnings.
These review the stmmac.txt where some new fields have not been
updated after adding new supports.
There is a patch to review the private structure trying to reorganize all the fields
in order to keep adjacent fields for cache effect (this patch is the V2 because
already discussed in the mailing list). I have seen that there are not
regressions when test on UP and SMP systems indeed.
In these patches I have removed two old patches for memory barrier and GRO.
We discussed about these in the mainling list and these had to be discarded.

Giuseppe Cavallaro (5):
  stmmac: review driver documentation
  stmmac: improve/review and fix kernel-doc
  stmmac: code tidy-up
  stmmac: review private structure fields
  stmmac: prefetch all dma_erx when use extend_desc

 Documentation/networking/stmmac.txt                |   12 +-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   12 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   89 ++--
 drivers/net/ethernet/stmicro/stmmac/descs.h        |    6 +-
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   69 ++--
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   70 ++--
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   23 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   28 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |   26 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |    3 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   72 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  462 ++++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |    8 +-
 19 files changed, 496 insertions(+), 401 deletions(-)

-- 
1.7.4.4
