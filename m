From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/5][SCTP]: Fix IPv6 address flag setting when doing
	peel-off/accept.
Date: Fri, 18 Aug 2006 11:22:42 -0700
Message-ID: <1155925362.20802.28.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:8597 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1161051AbWHRS2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 14:28:50 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7IISo5u019148
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:50 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7IISnR8288708
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7IISnaY010261
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:49 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix IPv6 address flag setting when doing peel-off/accept.

During accept/peeloff we try to copy the list of bound addresses from
the original endpoint to the new one. However, we forgot to set the flag
to say that IPv6 is allowed on the new endpoint.

Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/socket.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 48eeb26..b289f8a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5606,6 +5606,8 @@ static void sctp_sock_migrate(struct soc
 	/* Copy the bind_addr list from the original endpoint to the new
 	 * endpoint so that we can handle restarts properly
 	 */
+	if (PF_INET6 == assoc->base.sk->sk_family)
+		flags = SCTP_ADDR6_ALLOWED;
 	if (assoc->peer.ipv4_address)
 		flags |= SCTP_ADDR4_PEERSUPP;
 	if (assoc->peer.ipv6_address)


