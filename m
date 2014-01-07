From: valentina.giusti@bmw-carit.de
Subject: [PATCH 2/2] utils: add test for nfq_get_uid and nfq_get_gid
Date: Tue,  7 Jan 2014 14:30:20 +0100
Message-ID: <1389101420-16557-3-git-send-email-valentina.giusti@bmw-carit.de>
References: <20131221113804.GA17964@localhost>
 <1389101420-16557-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, fw@strlen.de, daniel.wagner@bmw-carit.de
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:51411 "EHLO
	linuxmail.bmw-carit.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751444AbaAGNaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 08:30:25 -0500
In-Reply-To: <1389101420-16557-1-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentina Giusti <Valentina.Giusti@bmw-carit.de>

Signed-off-by: Valentina Giusti <Valentina.Giusti@bmw-carit.de>
---
 utils/nfqnl_test.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/utils/nfqnl_test.c b/utils/nfqnl_test.c
index a554f2d..c6b97c6 100644
--- a/utils/nfqnl_test.c
+++ b/utils/nfqnl_test.c
@@ -15,7 +15,7 @@ static u_int32_t print_pkt (struct nfq_data *tb)
 	int id = 0;
 	struct nfqnl_msg_packet_hdr *ph;
 	struct nfqnl_msg_packet_hw *hwph;
-	u_int32_t mark,ifi; 
+	u_int32_t mark, ifi, uid, gid;
 	int ret;
 	unsigned char *data;
 
@@ -55,6 +55,12 @@ static u_int32_t print_pkt (struct nfq_data *tb)
 	if (ifi)
 		printf("physoutdev=%u ", ifi);
 
+	if (nfq_get_uid(tb, &uid))
+		printf("uid=%u ", uid);
+
+	if (nfq_get_gid(tb, &gid))
+		printf("gid=%u ", gid);
+
 	ret = nfq_get_payload(tb, &data);
 	if (ret >= 0)
 		printf("payload_len=%d ", ret);
@@ -114,6 +120,10 @@ int main(int argc, char **argv)
 		exit(1);
 	}
 
+	printf("setting flags to request UID and GID\n");
+	if (nfq_set_queue_flags(qh, NFQA_CFG_F_UID_GID, NFQA_CFG_F_UID_GID))
+		fprintf(stderr, "can't request UID_GID flag\n");
+
 	fd = nfq_fd(h);
 
 	for (;;) {
-- 
1.8.5.1
