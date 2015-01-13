From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] af_packet: fix typo of "unlikely" conditional in packet_snd
Date: Tue, 13 Jan 2015 14:20:11 -0500
Message-ID: <1421176811-22594-1-git-send-email-linville@tuxdriver.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48225 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbAMTUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:20:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change "unlikely(offset) < 0" to "unlikely(offset < 0)"...

Coverity: CID 1259984

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Compile tested only...

 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6880f34a529a..9cfe2e1dd8b5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2517,7 +2517,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	err = -EINVAL;
 	if (sock->type == SOCK_DGRAM) {
 		offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len);
-		if (unlikely(offset) < 0)
+		if (unlikely(offset < 0))
 			goto out_free;
 	} else {
 		if (ll_header_truncated(dev, len))
-- 
2.1.0
