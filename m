From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 01/11] sctp: remove the typedef sctp_ipv4addr_param_t
Date: Wed,  5 Jul 2017 08:32:19 +0800
Message-ID: <6ba452f31d10acdc95f3cf679ecab15833f7843c.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36057 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752295AbdGEAcq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:32:46 -0400
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_ipv4addr_param_t, and replace
with struct sctp_ipv4addr_param in the places where it's using this
typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     | 6 +++---
 net/sctp/protocol.c      | 2 +-
 net/sctp/sm_make_chunk.c | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 99e8664..e42095d 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -273,10 +273,10 @@ struct sctp_init_chunk {
 
 
 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
-typedef struct sctp_ipv4addr_param {
+struct sctp_ipv4addr_param {
 	struct sctp_paramhdr param_hdr;
-	struct in_addr  addr;
-} sctp_ipv4addr_param_t;
+	struct in_addr addr;
+};
 
 /* Section 3.3.2.1. IPv6 Address Parameter (6) */
 typedef struct sctp_ipv6addr_param {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 989a900..852556d 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -292,7 +292,7 @@ static void sctp_v4_from_addr_param(union sctp_addr *addr,
 static int sctp_v4_to_addr_param(const union sctp_addr *addr,
 				 union sctp_addr_param *param)
 {
-	int length = sizeof(sctp_ipv4addr_param_t);
+	int length = sizeof(struct sctp_ipv4addr_param);
 
 	param->v4.param_hdr.type = SCTP_PARAM_IPV4_ADDRESS;
 	param->v4.param_hdr.length = htons(length);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 4e16b02..0dc64da 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3153,7 +3153,7 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 		case SCTP_PARAM_ERR_CAUSE:
 			break;
 		case SCTP_PARAM_IPV4_ADDRESS:
-			if (length != sizeof(sctp_ipv4addr_param_t))
+			if (length != sizeof(struct sctp_ipv4addr_param))
 				return false;
 			/* ensure there is only one addr param and it's in the
 			 * beginning of addip_hdr params, or we reject it.
-- 
2.1.0
