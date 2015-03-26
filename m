From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/2] Fixes ingress queue mapping and other fixes
Date: Thu, 26 Mar 2015 10:04:24 +0530
Message-ID: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4700 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750742AbbCZE2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 00:28:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The below series fixes ingress queue mapping by allocating them dynamically to
prevent stack overflow. Disable napi and interrupts before unregistering netdev
to avoid crash while unloading driver when traffic is flowing.

The patches series is created against 'net' tree. 
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Allocate dynamic mem. for egress and ingress queue maps
  cxgb4: Disable interrupts and napi before unregistering netdev

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   12 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  104 ++++++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    7 +-
 3 files changed, 101 insertions(+), 22 deletions(-)
