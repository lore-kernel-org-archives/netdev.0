From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] drivers/net/macvtap: fix error check
Date: Sat, 5 Mar 2011 00:49:41 +0100
Message-ID: <20110305004941.7b195e9d@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:55168 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760398Ab1CEBN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 20:13:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'len' is unsigned of type size_t and can't be negative.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 drivers/net/macvtap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5933621..fc27a99 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -528,8 +528,9 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 		vnet_hdr_len = q->vnet_hdr_sz;
 
 		err = -EINVAL;
-		if ((len -= vnet_hdr_len) < 0)
+		if (len < vnet_hdr_len)
 			goto err;
+		len -= vnet_hdr_len;
 
 		err = memcpy_fromiovecend((void *)&vnet_hdr, iv, 0,
 					   sizeof(vnet_hdr));
-- 
1.7.3.4
