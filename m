From: Jussi Maki <joamaki@gmail.com>
Subject: [PATCH] Fix xfrm hash collisions by changing __xfrm4_daddr_saddr_hash
 to hash addresses with addition
Date: Fri, 7 Aug 2009 10:38:14 +0300 (EEST)
Message-ID: <alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net>
References: <20090805.120831.66033097.davem@davemloft.net> <ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com> <alpine.DEB.1.10.0908061147060.3426@sisapiiri.net.net> <20090806.104034.186857842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:50989 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757022AbZHGHiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 03:38:50 -0400
Received: by bwz9 with SMTP id 9so1212608bwz.41
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 00:38:50 -0700 (PDT)
In-Reply-To: <20090806.104034.186857842.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes hash collisions in cases where number
of entries have incrementing IP source and destination addresses
from single respective subnets (i.e. 192.168.0.1-172.16.0.1, 
192.168.0.2-172.16.0.2, and so on.).

Signed-off-by: Jussi Maki <joamaki@gmail.com>
---
 net/xfrm/xfrm_hash.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index d401dc8..e5195c9 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -16,7 +16,7 @@ static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
 
 static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
-	return ntohl(daddr->a4 ^ saddr->a4);
+	return ntohl(daddr->a4 + saddr->a4);
 }
 
 static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
-- 
1.5.6.5

