From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 0/4][net-next] gianfar: Address napi polling issues
Date: Tue, 19 Mar 2013 19:40:01 +0200
Message-ID: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:47572 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757206Ab3CSRlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:41:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David, Paul,

These patches take on several issues in the current napi polling
routine, affecting mostly the newer Multi Queue Multi Group
(MQ_MG_MODE) devices. Seems that the code for these devices
has been neglected.

Tested on p1010 (single core, multi q), p1020 (dual core, multi q)
and p2020 (dual core, single q mode).

Thanks.

Claudiu Manoil (4):
  gianfar: Fix tx napi polling
  gianfar: Poll only active Rx queues
  gianfar: Remove redundant programming of [rt]xic registers
  gianfar: Refactor config coalescing calls for all queues

 drivers/net/ethernet/freescale/gianfar.c         | 135 +++++++++++++----------
 drivers/net/ethernet/freescale/gianfar.h         |   7 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   2 +-
 3 files changed, 84 insertions(+), 60 deletions(-)

-- 
1.7.11.3
