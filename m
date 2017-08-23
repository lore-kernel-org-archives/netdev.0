From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V2 PATCH net-next 1/5] xdp: remove bpf_warn_invalid_xdp_redirect
Date: Wed, 23 Aug 2017 12:15:20 +0200
Message-ID: <150348332000.23476.2108908505323595829.stgit@firesoul>
References: <150348327373.23476.14851572406177222309.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45178 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753834AbdHWKPX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 06:15:23 -0400
In-Reply-To: <150348327373.23476.14851572406177222309.stgit@firesoul>
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
index fa2115695037..31c579749679 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2499,7 +2499,6 @@ static int __bpf_tx_xdp(struct net_device *dev,
 	int err;
 
 	if (!dev->netdev_ops->ndo_xdp_xmit) {
-		bpf_warn_invalid_xdp_redirect(dev->ifindex);
 		return -EOPNOTSUPP;
 	}
 
@@ -2572,7 +2571,6 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	if (unlikely(!fwd)) {
-		bpf_warn_invalid_xdp_redirect(index);
 		err = -EINVAL;
 		goto out;
 	}
@@ -2593,7 +2591,6 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
 	dev = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	if (unlikely(!dev)) {
-		bpf_warn_invalid_xdp_redirect(index);
 		goto err;
 	}
 
@@ -3573,11 +3570,6 @@ void bpf_warn_invalid_xdp_action(u32 act)
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
