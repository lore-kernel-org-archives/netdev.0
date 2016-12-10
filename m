From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/5] net: ethernet: ti: cpsw: improve re-split policy
Date: Sat, 10 Dec 2016 14:23:45 +0200
Message-ID: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patches add several simplifications and improvements to set
maximum rate for channels taking in account switch and dual emac mode.

Don't re-split res in the following cases:
- speed of phys is not changed
- speed of phys is changed and no rate limited channels
- speed of phys is changed and all channels are rate limited
- phy is unlinked while dev is open
- phy is linked back but speed is not changed

The maximum speed is sum of "linked" phys, thus res are split taken
into account two interfaces, both for dual emac mode and for
switch mode.

Tested on am572x

Based on net-next/master

Ivan Khoronzhuk (5):
  net: ethernet: ti: cpsw: use same macros to get active slave
  net: ethernet: ti: cpsw: don't start queue twice
  net: ethernet: ti: cpsw: combine budget and weight split and check
  net: ethernet: ti: cpsw: re-split res only when speed is changed
  net: ethernet: ti: cpsw: sync rates for channels in dual emac mode

 drivers/net/ethernet/ti/cpsw.c | 178 +++++++++++++++++++++++------------------
 1 file changed, 99 insertions(+), 79 deletions(-)

-- 
2.7.4
