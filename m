From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: fix interrupt mitigation with raw sockets
Date: Wed, 17 Mar 2010 16:43:50 +0200
Message-ID: <20100317144350.GB3984__23151.0954945863$1268837428$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Juan Quintela <quintela@redhat.com>,
	Unai Uribarri <unai.uribarri@optenet.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606Ab0CQOtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 10:49:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A thinko in code means we never trigger interrupt
mitigation. Fix this.

Reported-by: Juan Quintela <quintela@redhat.com>
Reported-by: Unai Uribarri <unai.uribarri@optenet.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index fcafb6b..a6a88df 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -125,7 +125,7 @@ static void handle_tx(struct vhost_net *net)
 	mutex_lock(&vq->mutex);
 	vhost_disable_notify(vq);
 
-	if (wmem < sock->sk->sk_sndbuf * 2)
+	if (wmem < sock->sk->sk_sndbuf / 2)
 		tx_poll_stop(net);
 	hdr_size = vq->hdr_size;
 
-- 
1.7.0.18.g0d53a5
