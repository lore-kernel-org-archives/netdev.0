From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/3] ipip: Add gro callbacks to ipip offload
Date: Tue,  9 Sep 2014 11:23:15 -0700
Message-ID: <1410286996-302-3-git-send-email-therbert@google.com>
References: <1410286996-302-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35423 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbaIISXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:23:50 -0400
Received: by mail-pd0-f182.google.com with SMTP id w10so4548319pde.27
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:23:50 -0700 (PDT)
In-Reply-To: <1410286996-302-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add inet_gro_receive and inet_gro_complete to ipip_offload to
support GRO.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/af_inet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d156b3c..6d6348d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1670,6 +1670,8 @@ static const struct net_offload ipip_offload = {
 	.callbacks = {
 		.gso_send_check = inet_gso_send_check,
 		.gso_segment	= inet_gso_segment,
+		.gro_receive	= inet_gro_receive,
+		.gro_complete	= inet_gro_complete,
 	},
 };
 
-- 
2.1.0.rc2.206.gedb03e5
