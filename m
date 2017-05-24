From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 0/5] net-next: stmmac: rework the speed selection
Date: Wed, 24 May 2017 09:16:42 +0200
Message-ID: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34388 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933229AbdEXHTK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 03:19:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

The current stmmac_adjust_link() part which handle speed have
some if (has_platform) code and my dwmac-sun8i will add more of them.

So we need to handle better speed selection.
Moreover the struct link member speed and port are hard to guess their
purpose. And their unique usage are to be combined for writing speed.

My first try was to create an adjust_link() in stmmac_ops but it duplicate some code

The current solution is to have direct value for 10/100/1000 and a mask for them.

The first 4 patchs fix some minor problem found in stmmac_adjust_link() and reported by Florian Fainelli in my previous serie.
The last patch is the real work.

This serie is tested on cubieboard2 (dwmac1000) and opipc (dwmac-sun8i).

Regards

Changes since v3:
- Added the patch #4 "Convert old_link to bool" as suggested by Joe Perches
- Changed the speedmask

Changes since v2:
- Use true/false for new_state in patch #1

Corentin Labbe (5):
  net: stmmac: Convert new_state to bool
  net: stmmac: Remove unnecessary parenthesis
  net: stmmac: use SPEED_xxx instead of raw value
  net: stmmac: Convert old_link to bool
  net: stmmac: rework the speed selection

 drivers/net/ethernet/stmicro/stmmac/common.h       |  8 ++--
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 26 +++++++-----
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  6 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 26 +++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 47 ++++++++--------------
 6 files changed, 57 insertions(+), 58 deletions(-)

-- 
2.13.0
