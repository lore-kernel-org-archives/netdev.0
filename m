From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 0/4] net: mvpp2: fix the mac address retrieval logic
Date: Thu, 24 Aug 2017 11:46:54 +0200
Message-ID: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

The MAC address retrieval logic was broken and when using the PPv2
driver on PPv2.2 engines I ended up using the same mac address on all
ports. This series of patches fixes this, and also tackle a possible bug
when defining the mac address in the device tree.

To fix this in a nice way I ended up using a dedicated function to
handle the mac retrieval logic. This can be hard to backport into stable
kernels. This is why I also made a quick fix which is easy to backport
(patch 1/14), to tackle down the PPv2.2 mac retrieval bug. Let me know
if this approach is the proper way to handle this or if I should do
something else.

Thanks!
Antoine

Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")

Antoine Tenart (4):
  net: mvpp2: fix the mac address used when using PPv2.2
  net: mvpp2: move the mac retrieval/copy logic into its own function
  net: mvpp2: fix use of the random mac address for PPv2.2
  net: mvpp2: fallback using h/w and random mac if the dt one isn't
    valid

 drivers/net/ethernet/marvell/mvpp2.c | 48 ++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 18 deletions(-)

-- 
2.13.5
