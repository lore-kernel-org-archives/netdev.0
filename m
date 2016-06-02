From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v3 7/7] sctp: improve debug message to also log curr pkt and new chunk size
Date: Thu,  2 Jun 2016 15:05:44 -0300
Message-ID: <b77fec5ed91323dcad8e56fbaeae62e6e1326d01.1464888550.git.marcelo.leitner@gmail.com>
References: <cover.1464888549.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161516AbcFBSGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 14:06:18 -0400
In-Reply-To: <cover.1464888549.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is useful for debugging packet sizes.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Tested-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 60499a69179d255c47da1fa19b73147917a050bf..90d2e125c2f5e0e1ecb33a7eab10772e5b39567c 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -182,7 +182,8 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 	sctp_xmit_t retval;
 	int error = 0;
 
-	pr_debug("%s: packet:%p chunk:%p\n", __func__, packet, chunk);
+	pr_debug("%s: packet:%p size:%lu chunk:%p size:%d\n", __func__,
+		 packet, packet->size, chunk, chunk->skb ? chunk->skb->len : -1);
 
 	switch ((retval = (sctp_packet_append_chunk(packet, chunk)))) {
 	case SCTP_XMIT_PMTU_FULL:
-- 
2.5.5
