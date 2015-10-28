From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 0/4] sfc: NUMA support
Date: Wed, 28 Oct 2015 15:00:13 +0000
Message-ID: <5630E2FD.3070609@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:45908 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbbJ1PA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 11:00:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for 
- allocating rx pages local to the interrupt
- setting affinity hint to influence IRQs to be allocated on the
same NUMA node as the one where the card resides.

Alexandra Kossovsky (1):
  sfc: use __GFP_NOWARN when allocating RX pages from atomic context.

Bert Kenward (2):
  sfc: Use cpu_to_mem() to support memoryless nodes
  sfc: set and clear interrupt affinity hints

Daniel Pieczko (1):
  sfc: allocate rx pages on the same node as the interrupt

 drivers/net/ethernet/sfc/efx.c        | 36 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |  3 +++
 drivers/net/ethernet/sfc/rx.c         | 18 +++++++++++++++---
 3 files changed, 54 insertions(+), 3 deletions(-)
