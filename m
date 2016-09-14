From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 0/7] add enhancement into the existing reset flow
Date: Wed, 14 Sep 2016 11:50:34 +0800
Message-ID: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:34258 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752626AbcINDuu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 23:50:50 -0400
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

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 227 +++++++++++++++++++++-------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  15 +-
 2 files changed, 187 insertions(+), 55 deletions(-)

-- 
1.9.1
