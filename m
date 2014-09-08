From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/5] ipip: Add gro callbacks to ipip offload
Date: Sun,  7 Sep 2014 22:26:26 -0700
Message-ID: <1410153989-23837-3-git-send-email-therbert@google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:44279 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHF1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 01:27:07 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so3081395pab.13
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 22:27:06 -0700 (PDT)
In-Reply-To: <1410153989-23837-1-git-send-email-therbert@google.com>
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
