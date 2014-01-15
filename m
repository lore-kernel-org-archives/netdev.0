From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH] batman-adv: fix batman-adv header overhead calculation
Date: Thu, 16 Jan 2014 00:10:44 +0100
Message-ID: <1389827444-3911-2-git-send-email-antonio@meshcoding.com>
References: <1389827444-3911-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:18759 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbaAOXL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:11:57 -0500
In-Reply-To: <1389827444-3911-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <mareklindner@neomailbox.ch>

Batman-adv prepends a full ethernet header in addition to its own
header. This has to be reflected in the MTU calculation, especially
since the value is used to set dev->hard_header_len.

Introduced by 411d6ed93a5d0601980d3e5ce75de07c98e3a7de
("batman-adv: consider network coding overhead when calculating require=
d mtu")

Reported-by: cmsv <cmsv@wirelesspt.net>
Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 1511f64..faba0f6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -277,7 +277,7 @@ int batadv_max_header_len(void)
 			   sizeof(struct batadv_coded_packet));
 #endif
=20
-	return header_len;
+	return header_len + ETH_HLEN;
 }
=20
 /**
--=20
1.8.5.3
