From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 0/2] Fix warnings in cxgb3
Date: Tue, 21 May 2013 19:51:27 +0530
Message-ID: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	santosh@chelsio.com, fenlason@redhat.com, vipul@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11502 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab3EUO1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 10:27:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first warning is about using rcu_dereference() when not in a rcu-locked
section. It only happens on initialization hence fix the initialization to not
rcu_dereference().

The second warning is about not checking that a *dma_map*() call succeeded.
This patch adds checks at approprate places.

We request this patch series to get merged via net-next tree.

Thanks,
Vipul

Jay Fenlason (1):
  cxgb3: Fix warning about using rcu_dereference when not in a
    rcu-locked section

Santosh Rastapur (1):
  cxgb3: Check and handle the dma mapping errors

 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   9 +-
 drivers/net/ethernet/chelsio/cxgb3/sge.c           | 105 ++++++++++++++++-----
 2 files changed, 87 insertions(+), 27 deletions(-)

-- 
1.8.0
