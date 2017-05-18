From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next v3 6/7] openvswitch: more accurate checksumming in queue_userspace_packet()
Date: Thu, 18 May 2017 15:44:42 +0200
Message-ID: <5b4820b5a47c1ea26e3c611a31c79ab30f6cf023.1495112302.git.dcaratti@redhat.com>
References: <cover.1495112301.git.dcaratti@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753786AbdERNpG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:45:06 -0400
In-Reply-To: <cover.1495112301.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if skb carries an SCTP packet and ip_summed is CHECKSUM_PARTIAL, it needs
CRC32c in place of Internet Checksum: use skb_csum_hwoffload_help to avoid
corrupting such packets while queueing them towards userspace.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/openvswitch/datapath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7b17da9..9ddc9f8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -453,7 +453,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	/* Complete checksum if needed */
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    (err = skb_checksum_help(skb)))
+	    (err = skb_csum_hwoffload_help(skb, 0)))
 		goto out;
 
 	/* Older versions of OVS user space enforce alignment of the last
-- 
2.7.4
