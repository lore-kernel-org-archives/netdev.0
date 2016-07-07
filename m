From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Thu,  7 Jul 2016 17:58:46 +0200
Message-ID: <cover.1467895623.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbcGGQAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 12:00:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
at the ingress device level. Currently both the geneve and the vxlan drivers
implement an additional GRO aggregation point via gro_cells.
The latter takes effect for tunnels using zero checksum udp packets, which are
currently explicitly not aggregated by the udp offload layer.

This patch series adapts the udp tunnel offload to process also zero checksum
udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
performed at the ingress device level.

Then the gro_cells hooks, in both vxlan and geneve driver are removed.

Paolo Abeni (4):
  udp_offload: simplify error path
  udp offload: allow GRO on 0 checksum packets
  vxlan: remove gro_cell support
  geneve: remove gro_cell support

 drivers/net/geneve.c   | 12 +-----------
 drivers/net/vxlan.c    |  9 ++-------
 include/net/vxlan.h    |  1 -
 net/ipv4/udp_offload.c | 12 +++++++-----
 4 files changed, 10 insertions(+), 24 deletions(-)

-- 
1.8.3.1
