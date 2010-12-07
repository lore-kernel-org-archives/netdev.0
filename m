From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] af_packet: fix freeing pg_vec twice on error path
Date: Tue,  7 Dec 2010 23:05:18 +0800
Message-ID: <1291734318-17989-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59429 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab0LGPLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 10:11:51 -0500
Received: by yxt3 with SMTP id 3so2512yxt.19
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 07:11:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is introduced in:
        commit 0e3125c755445664f00ad036e4fc2cd32fd52877
        Author: Neil Horman <nhorman@tuxdriver.com>
        Date:   Tue Nov 16 10:26:47 2010 -0800
    
        packet: Enhance AF_PACKET implementation to not require high order contiguous memory allocation (v4)

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/packet/af_packet.c |    1 -
 1 file changed, 1 deletion(-)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0e152b1..d163f78 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2408,7 +2408,6 @@ out:
 
 out_free_pgvec:
 	free_pg_vec(pg_vec, order, block_nr);
-	kfree(pg_vec);
 	pg_vec = NULL;
 	goto out;
 }
