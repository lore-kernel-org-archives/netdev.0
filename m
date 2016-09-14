From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 0/7] add enhancement into the existing reset flow
Date: Wed, 14 Sep 2016 23:13:14 +0800
Message-ID: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:14572 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1760246AbcINPNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 11:13:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Current driver only resets DMA used by descriptor rings which
can't guarantee it can recover all various kinds of fatal
errors, so the patch
1) tries to reset the underlying hardware resource from scratch on
Mediatek SoC required for ethernet running.
2) refactors code in order to the reusability of existing code.
3) considers handling for race condition between the reset flow and
callbacks registered into core driver called about hardware accessing.
4) introduces power domain usage to hardware setup which leads to have
cleanly and completely restore to the state as the initial.

Changes since v1:
- fix the build error with module built causing undefined symbol for
  pinctrl_bind_pins, so using pinctrl_select_state instead accomplishes
  the pin mux setup during the reset process.

Sean Wang (7):
  net: ethernet: mediatek: refactoring mtk_hw_init to be reused
  net: ethernet: mediatek: add mtk_hw_deinit call as the opposite to
    mtk_hw_init call
  net: ethernet: mediatek: cleanup error path inside mtk_hw_init
  net: ethernet: mediatek: add controlling power domain the ethernet
    belongs to
  net: ethernet: mediatek: add the whole ethernet reset into the reset
    process
  net: ethernet: mediatek: add more resets for internal ethernet circuit
    block
  net: ethernet: mediatek: avoid race condition during the reset process

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 226 +++++++++++++++++++++-------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  15 +-
 2 files changed, 186 insertions(+), 55 deletions(-)

-- 
1.9.1
