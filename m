From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/2] dccp: support for passing MSG_TRUNC
Date: Thu, 11 Feb 2010 07:26:18 +0100
Message-ID: <1265869579-5829-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <udp_dccp_msg_trunc>
 <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51486 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751642Ab0BKG0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 01:26:40 -0500
In-Reply-To: <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCCP is datagram-oriented but lacks UDP's support for MSG_TRUNC as defined in
recvmsg(2)/recv(2). Hence the following 'Hello world\0' receiver

  len = recv(fd, buf, 10, MSG_PEEK | MSG_TRUNC);

wrongly (always) returns 10, while in UDP it returns 12 as expected.
This patch adds the missing MSG_TRUNC support to recvmsg().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/proto.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -835,6 +835,8 @@ verify_sock_status:
 			len = -EFAULT;
 			break;
 		}
+		if (flags & MSG_TRUNC)
+			len = skb->len;
 	found_fin_ok:
 		if (!(flags & MSG_PEEK))
 			sk_eat_skb(sk, skb, 0);
