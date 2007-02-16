From: Max Krasnyansky <maxk@qualcomm.com>
Subject: [TIPC] Missing null check in the socket code.
Date: Thu, 15 Feb 2007 22:27:34 -0800
Message-ID: <11716072541171-git-send-email-maxk@qualcomm.com>
References: <1171607254637-git-send-email-maxk@qualcomm.com>
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:48753 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965331AbXBPHD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 02:03:28 -0500
Received: from ithilien.qualcomm.com (ithilien.qualcomm.com [129.46.51.59])
	by warlock.qualcomm.com (8.13.6/8.13.6/1.0) with ESMTP id l1G6csRH019969
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 22:38:55 -0800 (PST)
In-Reply-To: <1171607254637-git-send-email-maxk@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes an oops in the non-blocking mode.

Signed-off-by: Max Krasnyansky <maxk@qualcomm.com>
---
 net/tipc/socket.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2a6a5a6..767f791 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -862,6 +862,10 @@ restart:
 	/* Get access to first message in receive queue */
 
 	buf = skb_peek(&sock->sk->sk_receive_queue);
+	if (NULL == buf) {
+		res = -EAGAIN;
+		goto exit;
+	}
 	msg = buf_msg(buf);
 	sz = msg_data_sz(msg);
 	err = msg_errcode(msg);
-- 
1.4.4.2

