From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/2] [SCTP] Unmap v4mapped addresses during SCTP_BINDX_REM_ADDR operation.
Date: Tue, 10 Apr 2007 17:21:24 -0400
Message-ID: <11762400843295-git-send-email-vladislav.yasevich@hp.com>
References: <11762400848-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Paolo Galtieri <pgaltieri@mvista.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39752 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896AbXDJVV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 17:21:28 -0400
In-Reply-To: <11762400848-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Galtieri <pgaltieri@mvista.com>

During the sctp_bindx() call to add additional addresses to the
endpoint, any v4mapped addresses are converted and stored as regular
v4 addresses.  However, when trying to remove these addresses, the
v4mapped addresses are not converted and the operation fails.  This
patch unmaps the addresses on during the remove operation as well.

Signed-off-by: Paolo Galtieri <pgaltieri@mvista.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 523e73e..a1d026f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -627,6 +627,12 @@ int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 			retval = -EINVAL;
 			goto err_bindx_rem;
 		}
+
+		if (!af->addr_valid(sa_addr, sp, NULL)) {
+			retval = -EADDRNOTAVAIL;
+			goto err_bindx_rem;
+		}
+
 		if (sa_addr->v4.sin_port != htons(bp->port)) {
 			retval = -EINVAL;
 			goto err_bindx_rem;
-- 
1.5.0.3.438.gc49b2

