From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP]: Add address type check while process paramaters of ASCONF chunk
Date: Fri,  9 May 2008 15:09:55 -0400
Message-ID: <1210360195-16524-2-git-send-email-vladislav.yasevich@hp.com>
References: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:17086 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853AbYEITKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 15:10:00 -0400
In-Reply-To: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If socket is create by AF_INET type, add IPv6 address to asoc will cause
kernel panic while packet is transmitted on that transport.

This patch add address type check before process paramaters of ASCONF
chunk. If peer is not support this address type, return with error
invald parameter.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 69a464f..6eeee53 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2827,6 +2827,19 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	union sctp_addr	addr;
 	union sctp_addr_param *addr_param;
 
+	switch (addr_param->v4.param_hdr.type) {
+	case SCTP_PARAM_IPV6_ADDRESS:
+		if (!asoc->peer.ipv6_address)
+			return SCTP_ERROR_INV_PARAM;
+		break;
+	case SCTP_PARAM_IPV4_ADDRESS:
+		if (!asoc->peer.ipv4_address)
+			return SCTP_ERROR_INV_PARAM;
+		break;
+	default:
+		return SCTP_ERROR_INV_PARAM;
+	}
+
 	addr_param = (union sctp_addr_param *)
 			((void *)asconf_param + sizeof(sctp_addip_param_t));
 
-- 
1.5.3.5

