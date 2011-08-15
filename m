From: nirmu@dev.mellanox.co.il
Subject: [PATCH] ethtool: RX NFC - Convert ip address to big endian.
Date: Mon, 15 Aug 2011 18:40:46 +0300
Message-ID: <1313422846-6550-1-git-send-email-nirmu@dev.mellanox.co.il>
Cc: netdev@vger.kernel.org, Nir Muchtar <nirmu@dev.mellanox.co.il>,
	Nir Muchtar <nirmu@mellanox.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33828 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab1HOPs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 11:48:58 -0400
Received: by fxh19 with SMTP id 19so3660366fxh.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 08:48:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nir Muchtar <nirmu@dev.mellanox.co.il>

Signed-off-by: Nir Muchtar <nirmu@mellanox.com>
---
Unless there's a reason that I'm missing to why the user
is expected to specify ip addresses in big endian format.

 rxclass.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/rxclass.c b/rxclass.c
index b227901..98d035b 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -704,7 +704,7 @@ static int rxclass_get_ulong(char *str, unsigned long long *val, int size)
 	return 0;
 }
 
-static int rxclass_get_ipv4(char *str, __be32 *val)
+static int rxclass_get_ipv4(char *str, u32 *val)
 {
 	if (!inet_pton(AF_INET, str, val))
 		return -1;
@@ -828,11 +828,11 @@ static int rxclass_get_val(char *str, unsigned char *p, u32 *flags,
 		break;
 	}
 	case OPT_IP4: {
-		__be32 val;
+		u32 val;
 		err = rxclass_get_ipv4(str, &val);
 		if (err)
 			return -1;
-		*(__be32 *)&p[opt->offset] = val;
+		*(__be32 *)&p[opt->offset] = htonl((u32)val);
 		if (opt->moffset >= 0)
 			*(__be32 *)&p[opt->moffset] = (__be32)mask;
 		break;
@@ -929,11 +929,11 @@ static int rxclass_get_mask(char *str, unsigned char *p,
 		break;
 	}
 	case OPT_IP4: {
-		__be32 val;
+		u32 val;
 		err = rxclass_get_ipv4(str, &val);
 		if (err)
 			return -1;
-		*(__be32 *)&p[opt->moffset] = ~val;
+		*(__be32 *)&p[opt->moffset] = ~htonl((u32)val);
 		break;
 	}
 	case OPT_MAC: {
-- 
1.7.1

