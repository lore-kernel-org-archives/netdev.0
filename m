From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-2.6] vlan: reset headers on accel emulation path
Date: Thu, 18 Aug 2011 18:35:45 +0200
Message-ID: <1313685345-2417-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, gregkh@suse.de, kaber@trash.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755150Ab1HRQf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 12:35:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's after all necessary to do reset headers here. The reason is we
cannot depend that it gets reseted in __netif_receive_skb once skb is
reinjected. For incoming vlanids without vlan_dev, vlan_do_receive()
returns false with skb != NULL and __netif_reveive_skb continues, skb is
not reinjected.

This might be good material for 3.0-stable as well

Reported-by: Mike Auty <mike.auty@gmail.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>

---
 net/8021q/vlan_core.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 5f27f8e..f1f2f7b 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -167,6 +167,8 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 	if (unlikely(!skb))
 		goto err_free;
 
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
 	return skb;
 
 err_free:
-- 
1.7.6

