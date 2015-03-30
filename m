From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 0/2] hv_netvsc: Eliminate memory allocation in the send path
Date: Sun, 29 Mar 2015 21:07:58 -0700
Message-ID: <1427688478-27950-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:36249
	"EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbbC3Cuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 22:50:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network protocol used to communicate with the host is the remote ndis (rndis)
protocol. We need to decorate each outgoing packet with a rndis header and
additional rndis state (rndis per-packet state). To manage this state, we
currently allocate memory in the transmit path. Eliminate this allocation by
requesting additional head room in the skb.


K. Y. Srinivasan (2):
  hyperv: Cleanup the test for freeing skb when we use sendbuf
    mechanism
  hyperv: Eliminate memory allocation in the packet send path

 drivers/net/hyperv/hyperv_net.h   |    3 +-
 drivers/net/hyperv/netvsc.c       |    9 ++++-
 drivers/net/hyperv/netvsc_drv.c   |   70 ++++++++++++++++++++++++++----------
 drivers/net/hyperv/rndis_filter.c |    2 +
 4 files changed, 61 insertions(+), 23 deletions(-)

-- 
1.7.4.1
