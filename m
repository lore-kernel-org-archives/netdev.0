From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v4 0/3] add hisilicon hip04 ethernet driver
Date: Fri, 28 Mar 2014 23:35:57 +0800
Message-ID: <1396020960-6170-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, linux@arm.linux.org.uk, arnd@arndb.de,
	f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
	mark.rutland@arm.com, David.Laight@ACULAB.COM,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56019 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbaC1Pgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 11:36:47 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so5013022pdb.0
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 08:36:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4:
Modify accoringly to the suggetion from Arnd, Florian, Eric, David
Use of_parse_phandle_with_fixed_args & syscon_node_to_regmap get ppe info
Add skb_orphan() and tx_timer for reclaim since no tx_finished interrupt
Update timeout, and move of_phy_connect to probe to reuse open/stop

v3:
Suggest from Arnd, use syscon & regmap_write/read to replace static void __iomem *ppebase.
Modify hisilicon-hip04-net.txt accrordingly to suggestion from Florian and Sergei.

v2:
Got many suggestions from Russell, Arnd, Florian, Mark and Sergei
Remove memcpy, use dma_map/unmap_single, use dma_alloc_coherent rather than dma_pool, etc.
Refer property in ethernet.txt, change ppe description, etc.

Zhangfei Gao (3):
  Documentation: add Device tree bindings for Hisilicon hip04 ethernet
  net: hisilicon: new hip04 MDIO driver
  net: hisilicon: new hip04 ethernet driver

 .../bindings/net/hisilicon-hip04-net.txt           |   88 +++
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/hisilicon/Kconfig             |   32 +
 drivers/net/ethernet/hisilicon/Makefile            |    5 +
 drivers/net/ethernet/hisilicon/hip04_eth.c         |  764 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hip04_mdio.c        |  186 +++++
 7 files changed, 1077 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
 create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
 create mode 100644 drivers/net/ethernet/hisilicon/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c

-- 
1.7.9.5
