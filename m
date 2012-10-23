From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next 2/2] packet: minor: make if case unlikely
Date: Tue, 23 Oct 2012 13:58:34 +0200
Message-ID: <20121023115833.GB8664@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59758 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab2JWL6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 07:58:38 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so1985844wey.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 04:58:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the character width of max. 80 chars and also marks the
if-statement as unlikely since those flags are not supported for the receive
path anyway.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/packet/af_packet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1f2f465..adb1931 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2601,7 +2601,8 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sockaddr_ll *sll;
 	int vnet_hdr_len = 0;
 
-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE)) {
+	if (unlikely(flags & ~(MSG_PEEK | MSG_DONTWAIT | MSG_TRUNC |
+			       MSG_CMSG_COMPAT | MSG_ERRQUEUE))) {
 		err = -EINVAL;
 		goto out;
 	}
