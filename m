From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 00/14] net: ethernet: ti: cpsw: split driver data and per ndev data
Date: Sat,  6 Aug 2016 13:48:30 +0300
Message-ID: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34300 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbcHFWCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2016 18:02:08 -0400
Received: by mail-lf0-f49.google.com with SMTP id l69so224719678lfg.1
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 15:02:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
v1: https://lkml.org/lkml/2016/8/4/616

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

Ivan Khoronzhuk (14):
  net: ethernet: ti: cpsw: simplify submit routine
  net: ethernet: ti: cpsw: remove redundant check in napi poll
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
  net: ethernet: ti: cpsw: move data platform data and slaves info to
    cpsw_common
  net: ethernet: ti: cpsw: fix int dbg message
  net: ethernet: ti: cpsw: move napi struct to cpsw_common
  net: ethernet: ti: cpsw: move ale, cpts and drivers params under
    cpsw_common

 drivers/net/ethernet/ti/cpsw.c | 879 +++++++++++++++++++++--------------------
 1 file changed, 447 insertions(+), 432 deletions(-)

-- 
1.9.1
