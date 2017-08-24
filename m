From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V3 PATCH net-next 1/5] xdp: remove bpf_warn_invalid_xdp_redirect
Date: Thu, 24 Aug 2017 12:33:03 +0200
Message-ID: <150357078339.26663.1700540432902545688.stgit@firesoul>
References: <150357074701.26663.4047992776649697788.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37356 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751849AbdHXKdH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 06:33:07 -0400
In-Reply-To: <150357074701.26663.4047992776649697788.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given there is a tracepoint that can track the error code
of xdp_do_redirect calls, the WARN_ONCE in bpf_warn_invalid_xdp_redirect
doesn't seem relevant any longer.  Simply remove the function.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 2a0d762a20d8..a5e5f31b41b9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2476,7 +2476,6 @@ static int __bpf_tx_xdp(struct net_device *dev,
 	int err;
 
 	if (!dev->netdev_ops->ndo_xdp_xmit) {
-		bpf_warn_invalid_xdp_redirect(dev->ifindex);
 		return -EOPNOTSUPP;
 	}
 
@@ -2543,7 +2542,6 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	if (unlikely(!fwd)) {
-		bpf_warn_invalid_xdp_redirect(index);
 		err = -EINVAL;
 		goto out;
 	}
@@ -2564,7 +2562,6 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
 	dev = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	if (unlikely(!dev)) {
-		bpf_warn_invalid_xdp_redirect(index);
 		return -EINVAL;
 	}
 
@@ -3565,11 +3562,6 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
-void bpf_warn_invalid_xdp_redirect(u32 ifindex)
-{
-	WARN_ONCE(1, "Illegal XDP redirect to unsupported device ifindex(%i)\n", ifindex);
-}
-
 static bool __is_valid_sock_ops_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct bpf_sock_ops))
