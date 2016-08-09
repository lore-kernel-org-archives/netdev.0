From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 00/13] net: ethernet: ti: cpsw: split driver data and per ndev data
Date: Wed, 10 Aug 2016 02:22:31 +0300
Message-ID: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In dual_emac mode the driver can handle 2 network devices. Each of them can use
its own private data and common data/resources. This patchset splits common driver
data/resources and private per net device data.
It leads to:
- reduce memory usage
- increase code readability
- allows add a bunch of simplification
- create prerequisites to add multi-channel support,
  when channels are shared between net devices

Doesn't have bad impact on performance.
v2: https://lkml.org/lkml/2016/8/6/108

Since v2:
- removed patch:
  net: ethernet: ti: cpsw: fix int dbg message
- replaced patch:
  "net: ethernet: ti: cpsw: remove redundant check in napi poll"
  on "net: ethernet: ti: cpsw: remove intr dbg msg from poll handlers"
- removed macro "cpsw_get_slave_ndev"
- corrected some commits

Since v1:
- added several patch improvements
- avoided variable reordering in structures
- removed static variable for common function
- split big patch on several patches:
  net: ethernet: ti: cpsw: remove priv from cpsw_get_slave_port() parameters list
  net: ethernet: ti: cpsw: remove clk var from priv
  net: ethernet: ti: cpsw: don't check slave num in runtime
  net: ethernet: ti: cpsw: create common struct to hold shared driver data
  net: ethernet: ti: cpsw: replace pdev on dev
  net: ethernet: ti: cpsw: move links on h/w registers to cpsw_common
  net: ethernet: ti: cpsw: move cpdma resources to cpsw_common
  net; ethernet: ti: cpsw: move irq stuff under cpsw_common
  net: ethernet: ti: cpsw: move data platform data and slaves info to cpsw_common
  net: ethernet: ti: cpsw: fix int dbg message
  net: ethernet: ti: cpsw: move napi struct to cpsw_common
  net: ethernet: ti: cpsw: move ale, cpts and drivers params under

Based on net-next/master

Ivan Khoronzhuk (13):
  net: ethernet: ti: cpsw: simplify submit routine
  net: ethernet: ti: cpsw: remove intr dbg msg from poll handlers
  net: ethernet: ti: cpsw: remove priv from cpsw_get_slave_port()
    parameters list
  net: ethernet: ti: cpsw: remove clk var from priv
  net: ethernet: ti: cpsw: don't check slave num in runtime
  net: ethernet: ti: cpsw: create common struct to hold shared driver
    data
  net: ethernet: ti: cpsw: replace pdev on dev
  net: ethernet: ti: cpsw: move links on h/w registers to cpsw_common
  net: ethernet: ti: cpsw: move cpdma resources to cpsw_common
  net; ethernet: ti: cpsw: move irq stuff under cpsw_common
  net: ethernet: ti: cpsw: move platform data and slaves info to
    cpsw_common
  net: ethernet: ti: cpsw: move napi struct to cpsw_common
  net: ethernet: ti: cpsw: move ale, cpts and drivers params under
    cpsw_common

 drivers/net/ethernet/ti/cpsw.c | 847 ++++++++++++++++++++---------------------
 1 file changed, 413 insertions(+), 434 deletions(-)

-- 
1.9.1
