From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Wed,  8 Apr 2015 00:40:47 +0200
Message-ID: <cover.1428445141.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54410 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbDGWlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:41:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series applies without error against v3.19 and davem-next as of
812034f11628aaaab0e2d7af1d3bc50a49eb396b ("cxgb4: Move ethtool related
code to a separate file").

. Changes since #1:
  - turned wmb() into dma_wmb() as suggested by davem and Alexander Duyck
    in patch 1 of 6.
  - forgot to reset rx_head_desc in rhine_reset_rbufs in patch 4 of 6.
  - removed rx_head_desc altogether in (*new*) patch 5 of 6
  - remoed some vlan receive uglyness in (*new*) patch 6 of 6.

Francois Romieu (6):
  via-rhine: commit receive buffer address before descriptor status
    update.
  via-rhine: add allocation helpers.
  via-rhine: gotoize rhine_open error path.
  via-rhine: forbid holes in the receive descriptor ring.
  via-rhine: kiss rx_head_desc goodbye.
  via-rhine: beautify vlan receive code.

 drivers/net/ethernet/via/via-rhine.c | 195 +++++++++++++++++++++--------------
 1 file changed, 115 insertions(+), 80 deletions(-)

-- 
Ueimor
