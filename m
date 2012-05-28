From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] 9p: BUG before corrupting memory
Date: Mon, 28 May 2012 18:00:45 +0200
Message-ID: <1338220845-25082-1-git-send-email-levinsasha928@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <levinsasha928@gmail.com>
To: davem@davemloft.net, ericvh@gmail.com,
	aneesh.kumar@linux.vnet.ibm.com, jvrao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62320 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360Ab2E1P7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 11:59:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BUG_ON() in pack_sg_list() would get triggered only one time after we've
corrupted some memory by sg_set_buf() into an invalid sg buffer.

I'm still working on figuring out why I manage to trigger that bug...

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/9p/trans_virtio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 5af18d1..2fd7305 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -192,10 +192,10 @@ static int pack_sg_list(struct scatterlist *sg, int start,
 		s = rest_of_page(data);
 		if (s > count)
 			s = count;
+		BUG_ON(index >= limit);
 		sg_set_buf(&sg[index++], data, s);
 		count -= s;
 		data += s;
-		BUG_ON(index > limit);
 	}
 
 	return index-start;
-- 
1.7.8.6
