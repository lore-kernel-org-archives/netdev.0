From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 0/4] net-next: stmmac: rework the speed selection
Date: Mon, 22 May 2017 14:33:43 +0200
Message-ID: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

The current stmmac_adjust_link() part which handle speed have
some if (has_platform) code and my dwmac-sun8i will add more of them.

So we need to handle better speed selection.
Moreover the struct link member speed and port are hard to guess their
purpose. And their unique usage are to be combined for writing speed.

My first try was to create an adjust_link() in stmmac_ops but it duplicate some code

The current solution is to have direct value for 10/100/1000 and a mask for them.

The first 3 patchs fix some minor problem found in stmmac_adjust_link() and reported by Florian Fainelli in my previous serie.
The last patch is the real work.

This serie is tested on cubieboard2 (dwmac1000) and opipc (dwmac-sun8i).

Regards

Changes since v2:
- use true/false for new_state in patch #1

Corentin Labbe (4):
  net: stmmac: Convert new_state to bool
  net: stmmac: Remove unnecessary parenthesis
  net: stmmac: use SPEED_xxx instead of raw value
  net: stmmac: rework the speed selection

 drivers/net/ethernet/stmicro/stmmac/common.h       |  8 +++---
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 26 ++++++++++--------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  6 +++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 26 ++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 31 +++++++---------------
 5 files changed, 48 insertions(+), 49 deletions(-)

-- 
2.13.0
