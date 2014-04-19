From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v8 0/3] add hisilicon hip04 ethernet driver
Date: Sat, 19 Apr 2014 09:12:57 +0800
Message-ID: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>
To: davem@davemloft.net, linux@arm.linux.org.uk, arnd@arndb.de,
	f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
	mark.rutland@arm.com, David.Laight@ACULAB.COM,
	eric.dumazet@gmail.com, xuwei5@hisilicon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37493 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595AbaDSBNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 21:13:11 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so1933674pab.23
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 18:13:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v8:
Use poll to reclaim xmitted buffer as workaround since no tx done interrupt 

v7:
Remove select NET_CORE in 0002

v6:
Suggest by Russell: Use netdev_sent_queue & netdev_completed_queue to solve latency issue 
Also shorten the period of timer, which is used to wakeup the queue since no
tx completed interrupt.

v5:
no big change, fix typo

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

 .../bindings/net/hisilicon-hip04-net.txt           |   88 ++
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/hisilicon/Kconfig             |   31 +
 drivers/net/ethernet/hisilicon/Makefile            |    5 +
 drivers/net/ethernet/hisilicon/hip04_eth.c         |  845 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hip04_mdio.c        |  185 +++++
 7 files changed, 1156 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
 create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
 create mode 100644 drivers/net/ethernet/hisilicon/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c

-- 
1.7.9.5
