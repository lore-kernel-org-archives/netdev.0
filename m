From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 8/9] ipvs: off by one in set_sctp_state()
Date: Tue, 23 Apr 2013 12:03:59 +0900
Message-ID: <1366686240-23493-9-git-send-email-horms@verge.net.au>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47358 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab3DWDEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 23:04:08 -0400
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 2 +-
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
1.8.2.1
