From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net v2 0/9] net: ethernet: mediatek: a couple of fixes
Date: Mon, 29 Aug 2016 13:03:14 +0800
Message-ID: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

a couple of fixes come out from integrating with linux-4.8 rc1
they all are verified and workable on linux-4.8 rc1

changes since v1:
- usage of loops to work out if all required clock are ready instead
of tedious coding
- remove redundant pinctrl setup that is already done by core driver
thanks for careful and patient reviewing by Andrew Lunn
- splitting distinct changes into the separate patches
- change variable naming from err to ret for readable coding

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
