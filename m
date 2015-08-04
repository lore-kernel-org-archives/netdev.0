From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 0/3] CPSW interrupt handling cleanup and performance improvement
Date: Tue, 4 Aug 2015 16:06:17 +0530
Message-ID: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:33437 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774AbbHDKgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 06:36:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes the irq controller disable interrupt and
adding a napi for tx event handling which improves the performance by
~180Mbps on dra7-evm

[  5] local 192.168.10.116 port 5001 connected with 192.168.10.165 port 44176
[  5]  0.0-60.0 sec  1.48 GBytes   210 Mbits/sec
[  4] local 192.168.10.116 port 5001 connected with 192.168.10.165 port 33257
[  4]  0.0-60.0 sec  2.71 GBytes   386 Mbits/sec

Changes from initial version: 
* Added a patch to have napi only for first interface as there is
  no use of having seperate napis for each interface as the
  interrupt is shared by both interface and only one napi is
  scheduled for each interrupt.

Mugunthan V N (3):
  drivers: net: cpsw: remove  disable_irq/enable_irq as irq can be
    masked from cpsw itself
  drivers: net: cpsw: dual_emac: simplify napi usage
  drivers: net: cpsw: add separate napi for tx

 drivers/net/ethernet/ti/cpsw.c | 83 ++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 48 deletions(-)

-- 
2.5.0.234.gefc8a62
