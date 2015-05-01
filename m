From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #3 0/8] via-rhine rework
Date: Fri,  1 May 2015 22:14:37 +0200
Message-ID: <cover.1430509434.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>, Nix <nix@esperi.org.uk>,
	Roger.Luethi.rl@hellgate.ch,
	Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51004 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbEAUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 16:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series applies against davem-next as of
9dd3c797496affd699805c8a9d8429ad318c892f ("drivers: net: xgene: fix kbuild
warnings").

Patches #1..#4 avoid holes in the receive ring.

Patch #5 is a small leftover cleanup for #1..#4.

Patches #6 and #7 are fairly simple barrier stuff.

Patch #8 closes some SMP transmit races - not that anyone really
complained about these but it's a bit hard to handwave that they
can be safely ignored. Some testing, especially SMP testing of
course, would be welcome.

. Changes since #2:
  - added dma_rmb barrier in vlan related patch 6.
  - s/wmb/dma_wmb/ in (*new*) patch 7 of 8.
  - added explicit SMP barriers in (*new*) patch 8 of 8.

. Changes since #1:
  - turned wmb() into dma_wmb() as suggested by davem and Alexander Duyck
    in patch 1 of 6.
  - forgot to reset rx_head_desc in rhine_reset_rbufs in patch 4 of 6.
  - removed rx_head_desc altogether in (*new*) patch 5 of 6
  - remoed some vlan receive uglyness in (*new*) patch 6 of 6.


Francois Romieu (8):
  via-rhine: commit receive buffer address before descriptor status update.
  via-rhine: allocate and map receive buffer in a single transaction
  via-rhine: gotoize rhine_open error path.
  via-rhine: forbid holes in the receive descriptor ring.
  via-rhine: kiss rx_head_desc goodbye.
  via-rhine: add consistent memory barrier in vlan receive code.
  via-rhine: dma_wmb transmit barrier.
  via-rhine: close SMP transmit races.

 drivers/net/ethernet/via/via-rhine.c | 249 +++++++++++++++++++++++------------
 1 file changed, 162 insertions(+), 87 deletions(-)

-- 
Ueimor
