From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 9/9] macsec: fix netlink attribute validation
Date: Fri, 22 Apr 2016 11:28:09 +0200
Message-ID: <1efcc1e7c8f1fcef54e58bbb7a498bb9419780a0.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754258AbcDVJ2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:46 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macsec_validate_attr should check IFLA_MACSEC_REPLAY_PROTECT (not
IFLA_MACSEC_PROTECT) to verify that the replay protection and replay
window arguments are correct.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 9f63cc7b0a73..c6385617bfb2 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3147,8 +3147,8 @@ static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
 	    nla_get_u8(data[IFLA_MACSEC_VALIDATION]) > MACSEC_VALIDATE_MAX)
 		return -EINVAL;
 
-	if ((data[IFLA_MACSEC_PROTECT] &&
-	     nla_get_u8(data[IFLA_MACSEC_PROTECT])) &&
+	if ((data[IFLA_MACSEC_REPLAY_PROTECT] &&
+	     nla_get_u8(data[IFLA_MACSEC_REPLAY_PROTECT])) &&
 	    !data[IFLA_MACSEC_WINDOW])
 		return -EINVAL;
 
-- 
2.8.0
