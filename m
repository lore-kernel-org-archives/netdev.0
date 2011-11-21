From: roy.qing.li@gmail.com
Subject: [PATCH] dccp: fix error propagation in dccp_v4_connect
Date: Mon, 21 Nov 2011 13:18:20 +0800
Message-ID: <1321852700-2966-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37774 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1KUFSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:18:25 -0500
Received: by iage36 with SMTP id e36so6810161iag.19
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 21:18:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

The errcode is not updated when ip_route_newports() fails.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/dccp/ipv4.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 90a919a..3f4e541 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -111,6 +111,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
 		rt = NULL;
 		goto failure;
 	}
-- 
1.7.1
