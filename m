From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP]: Do not enable peer IPv6 address support on PF_INET socket
Date: Fri,  9 May 2008 15:09:54 -0400
Message-ID: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:10400 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbYEITJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 15:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If socket is create by PF_INET type, it can not used IPv6 address to
send/recv DATA, So we can not used IPv6 address even if peer tell us it
support IPv6 address.
This patch fix to only enabled peer IPv6 address support on PF_INET6 socket.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 81b6064..69a464f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2418,7 +2418,8 @@ static int sctp_process_param(struct sctp_association *asoc,
 				break;
 
 			case SCTP_PARAM_IPV6_ADDRESS:
-				asoc->peer.ipv6_address = 1;
+				if (PF_INET6 == asoc->base.sk->sk_family)
+					asoc->peer.ipv6_address = 1;
 				break;
 
 			case SCTP_PARAM_HOST_NAME_ADDRESS:
-- 
1.5.3.5

