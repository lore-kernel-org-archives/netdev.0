From: <sean.wang@mediatek.com>
Subject: [PATCH net v4 0/9] net: ethernet: mediatek: a couple of fixes
Date: Thu, 1 Sep 2016 10:47:26 +0800
Message-ID: <1472698055-8821-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:4830 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754918AbcIACrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 22:47:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

a couple of fixes come out from integrating with linux-4.8 rc1
they all are verified and workable on linux-4.8 rc1

Changes since v1:
- usage of loops to work out if all required clock are ready instead
of tedious coding
- remove redundant pinctrl setup that is already done by core driver
thanks for careful and patient reviewing by Andrew Lunn
- splitting distinct changes into the separate patches
- change variable naming from err to ret for readable coding

Changes since v2:
- restore to original clock disabling sequence that is changed 
accidentally in the last version
- refine the commit log that would cause misunderstanding what has 
been done in the changes
- refine the commit log that would cause footnote losing due to 
improper delimiter use

Changes since v3:
- fix git rejects caused by mixing a change from net-next, so 
remake the patch set based on the current net branch again.

Sean Wang (9):
  net: ethernet: mediatek: fix fails from TX housekeeping due to
    incorrect port setup
  net: ethernet: mediatek: fix incorrect return value of devm_clk_get
    with EPROBE_DEFER
  net: ethernet: mediatek: fix API usage with skb_free_frag
  net: ethernet: mediatek: remove redundant free_irq for
    devm_request_irq allocated irq
  net: ethernet: mediatek: fix logic unbalance between probe and remove
  net: ethernet: mediatek: fix issue of driver removal with interface is
    up
  net: ethernet: mediatek: fix the missing of_node_put() after node is
    used done inside mtk_mdio_init
  net: ethernet: mediatek: use devm_mdiobus_alloc instead of
    mdiobus_alloc inside mtk_mdio_init
  net: ethernet: mediatek: fix error handling inside mtk_mdio_init

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 82 +++++++++++++++--------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 22 +++++---
 2 files changed, 56 insertions(+), 48 deletions(-)

-- 
1.9.1
