From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] net/9p: Add device name details on error
Date: Thu,  3 Sep 2015 13:36:51 +0530
Message-ID: <1441267611-7451-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:57770 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbbICII4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 04:08:56 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 3 Sep 2015 13:37:28 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id A0FFAE008A
	for <netdev@vger.kernel.org>; Thu,  3 Sep 2015 13:36:22 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8386vsq8257734
	for <netdev@vger.kernel.org>; Thu, 3 Sep 2015 13:36:59 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8386u2I031636
	for <netdev@vger.kernel.org>; Thu, 3 Sep 2015 13:36:57 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we use wrong device name 9p mount fails with error

"9pnet_virtio: no channels available"

Improve the error output as below

"9pnet_virtio: no channels available for device /dev/root"

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 net/9p/trans_virtio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 6e70ddb158b4..3827760c8eef 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -662,7 +662,7 @@ p9_virtio_create(struct p9_client *client, const char *devname, char *args)
 	mutex_unlock(&virtio_9p_lock);
 
 	if (!found) {
-		pr_err("no channels available\n");
+		pr_err("no channels available for device %s\n", devname);
 		return ret;
 	}
 
-- 
2.5.0
