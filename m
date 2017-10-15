From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 15 Oct 2017 19:22:26 +0300
Message-ID: <20171015162226.606-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52617 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751502AbdJOQ2K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 43A0E191876
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:21:50 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX optimizations have led to ~15% performance increase (35->40Mbps)
in local tx usecase (tested with iperf v3.2).

Roman Yeryomin (10):
  net: korina: optimize korina_send_packet logic
  net: korina: reorder functions
  net: korina: introduce and use interrupt disable/enable helpers
  net: korina: optimize tx/rx interrupt handlers
  net: korina: remove unused korina_private members
  net: korina: optimize tx descriptor flags processing
  net: korina: move tx to napi context
  net: korina: optimize tx_full condition
  net: korina: use dma api instead of dma_cache_* functions
  net: korina: bump version

 drivers/net/ethernet/korina.c | 503 +++++++++++++++++-------------------------
 1 file changed, 204 insertions(+), 299 deletions(-)

-- 
2.11.0
