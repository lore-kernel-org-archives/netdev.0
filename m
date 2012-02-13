From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] virtio: net: remove sparse errors
Date: Mon, 13 Feb 2012 17:53:41 +0100
Message-ID: <1329152021.2494.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63036 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446Ab2BMQxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 11:53:45 -0500
Received: by wgbdt10 with SMTP id dt10so5077706wgb.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 08:53:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3fa2a1df909 (virtio-net: per cpu 64 bit stats (v2)) added extra
__percpu qualifiers and sparse errors.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4880aa8..83c503e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -255,7 +255,7 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	struct sk_buff *skb;
 	struct page *page;
 	struct skb_vnet_hdr *hdr;
@@ -549,7 +549,7 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
-	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
 	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
@@ -688,8 +688,7 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 	unsigned int start;
 
 	for_each_possible_cpu(cpu) {
-		struct virtnet_stats __percpu *stats
-			= per_cpu_ptr(vi->stats, cpu);
+		struct virtnet_stats *stats = per_cpu_ptr(vi->stats, cpu);
 		u64 tpackets, tbytes, rpackets, rbytes;
 
 		do {
