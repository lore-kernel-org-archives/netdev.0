From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO path
Date: Wed, 21 Jan 2015 09:54:08 -0300
Message-ID: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: B38611@freescale.com, fabio.estevam@freescale.com,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:36471 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753394AbbAUM4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:56:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two commits are fixes to the issue reported by Russell King on
mv643xx_eth. Namely, the introduction of a regression by commit 69ad0dd7af22
which removed the support for highmem skb fragments. The guilty commit
introduced the assumption of fragment's payload being located in lowmem pages.

A similar pattern can be found in the original mvneta driver (in fact, the
regression was introduced by copy-pasting the mvneta code).

These fixes are for the non-TSO egress path in mvneta and mv643xx_eth drivers.
The TSO path needs a more intrusive change, as the TSO API needs to be fixed
(e.g. to make it work in skb fragments, instead of pointers to data).

Russell, as I'm still unable to reproduce this, do you think you can
give it a spin over there?

Ezequiel Garcia (2):
  net: mvneta: Fix highmem support in the non-TSO egress path
  net: mv643xx_eth: Fix highmem support in non-TSO egress path

 drivers/net/ethernet/marvell/mv643xx_eth.c | 26 ++++++++++++++------
 drivers/net/ethernet/marvell/mvneta.c      | 39 ++++++++++++++++++------------
 2 files changed, 43 insertions(+), 22 deletions(-)

-- 
2.2.1
