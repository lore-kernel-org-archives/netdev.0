From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 11:04:45 +0200
Message-ID: <cover.1460393493.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759637AbcDMJFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 05:05:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series try to remove the need for any lock in the tun device
xmit path, significantly improving the forwarding performance when multiple
processes are accessing the tun device (i.e. in a nic->bridge->tun->vm scenario).

The lockless xmit is obtained explicitly setting the NETIF_F_LLTX feature bit
and removing the default qdisc.

Unlikely most virtual devices, the tun driver has featured a default qdisc
for a long period, but it already lost such feature in linux 4.3.

Paolo Abeni (2):
  tun: don't require serialization lock on tx
  tun: don't set a default qdisc

 drivers/net/tun.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-- 
1.8.3.1
