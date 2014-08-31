From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/6] vxlan: Enable checksum unnecessary conversions for vxlan/UDP sockets
Date: Sun, 31 Aug 2014 15:12:45 -0700
Message-ID: <1409523166-9215-6-git-send-email-therbert@google.com>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:39288 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbaHaWNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:30 -0400
Received: by mail-pd0-f181.google.com with SMTP id fp1so4621244pdb.12
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:30 -0700 (PDT)
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 67527f3..53c3ec1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2370,6 +2370,8 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 	/* Disable multicast loopback */
 	inet_sk(sock->sk)->mc_loop = 0;
 
+	udp_set_convert_csum(sock->sk, true);
+
 	return sock;
 }
 
-- 
2.1.0.rc2.206.gedb03e5
