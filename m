From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH] sctp: kzalloc() error handling on deleting last address
Date: Fri, 10 Jun 2011 17:07:56 +0900
Message-ID: <F8A1B797-89A2-4AAA-AFB1-9B187AC08456@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:39169 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754435Ab1FJIIB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 04:08:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 49a66ecad72af8c367b125c695a113d3f3870320 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Fri, 10 Jun 2011 16:42:14 +0900
Subject: [PATCH] sctp: kzalloc() error handling on deleting last address

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
 net/sctp/socket.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e7e1b14..a23d898 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -786,6 +786,8 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 				continue;
 			asoc->asconf_addr_del_pending =
 			    kzalloc(sizeof(union sctp_addr), GFP_ATOMIC);
+			if (asoc->asconf_addr_del_pending == NULL) 
+				continue;
 			asoc->asconf_addr_del_pending->sa.sa_family =
 				    addrs->sa_family;
 			asoc->asconf_addr_del_pending->v4.sin_port =
-- 
1.7.3.2


