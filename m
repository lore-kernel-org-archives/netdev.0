From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] NFC: Fix possible NULL ptr deref when getting the name of a socket
Date: Wed,  6 Jun 2012 23:02:55 +0200
Message-ID: <1339016575-18268-1-git-send-email-levinsasha928@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>
To: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, davem@davemloft.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:57703 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab2FFVBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 17:01:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

llcp_sock_getname() might get called before the LLCP socket was created.
This condition isn't checked, and llcp_sock_getname will simply deref a
NULL ptr in that case.

This exists starting with d646960 ("NFC: Initial LLCP support").

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/nfc/llcp/sock.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 3f339b1..17a707d 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -292,6 +292,9 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *addr,
 
 	pr_debug("%p\n", sk);
 
+	if (llcp_sock == NULL)
+		return -EBADFD;
+
 	addr->sa_family = AF_NFC;
 	*len = sizeof(struct sockaddr_nfc_llcp);
 
-- 
1.7.8.6
