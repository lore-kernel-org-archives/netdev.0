From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: use scnprintf() to avoid potential buffer overflow
Date: Wed, 25 Aug 2010 07:32:58 +0800
Message-ID: <1282692778-2945-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:52271 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932927Ab0HXXdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 19:33:16 -0400
Received: by pxi10 with SMTP id 10so2830471pxi.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 16:33:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

strlcpy() returns the total length of the string they tried to create, so
we should not use its return value without any check. scnprintf() returns
the number of characters written into @buf not including the trailing '\0',
so use it instead here.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ethernet/eth.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 215c839..85e7b45 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -367,7 +367,7 @@ struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count)
 EXPORT_SYMBOL(alloc_etherdev_mq);
 
 static size_t _format_mac_addr(char *buf, int buflen,
-				const unsigned char *addr, int len)
+			       const unsigned char *addr, int len)
 {
 	int i;
 	char *cp = buf;
@@ -376,7 +376,7 @@ static size_t _format_mac_addr(char *buf, int buflen,
 		cp += scnprintf(cp, buflen - (cp - buf), "%02x", addr[i]);
 		if (i == len - 1)
 			break;
-		cp += strlcpy(cp, ":", buflen - (cp - buf));
+		cp += scnprintf(cp, buflen - (cp - buf), ":");
 	}
 	return cp - buf;
 }
@@ -386,7 +386,7 @@ ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 	size_t l;
 
 	l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
-	l += strlcpy(buf + l, "\n", PAGE_SIZE - l);
+	l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
 	return ((ssize_t) l);
 }
 EXPORT_SYMBOL(sysfs_format_mac);
