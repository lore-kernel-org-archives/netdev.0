From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/10] ipvs: off by one in set_sctp_state()
Date: Thu, 25 Apr 2013 02:22:19 +0200
Message-ID: <1366849341-10466-9-git-send-email-pablo@netfilter.org>
References: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41139 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932264Ab3DYAWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 20:22:39 -0400
In-Reply-To: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

The sctp_events[] come from sch->type in set_sctp_state().  They are
between 0-255 so that means we need 256 elements in the array.

I believe that because of how the code is aligned there is normally a
hole after sctp_events[] so this patch doesn't actually change anything.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 6e14a7b..8646488 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -208,7 +208,7 @@ enum ipvs_sctp_event_t {
 	IP_VS_SCTP_EVE_LAST
 };
 
-static enum ipvs_sctp_event_t sctp_events[255] = {
+static enum ipvs_sctp_event_t sctp_events[256] = {
 	IP_VS_SCTP_EVE_DATA_CLI,
 	IP_VS_SCTP_EVE_INIT_CLI,
 	IP_VS_SCTP_EVE_INIT_ACK_CLI,
-- 
1.7.10.4
