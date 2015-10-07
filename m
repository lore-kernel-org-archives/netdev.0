From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] ip neigh: Add ifindex to request when filtering dumps by device
Date: Wed,  7 Oct 2015 10:23:24 -0700
Message-ID: <1444238604-12632-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32910 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352AbbJGRXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 13:23:30 -0400
Received: by pacex6 with SMTP id ex6so27104521pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 10:23:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ifindex to dump request when filtering by device. If the kernel
supports it adding the index to the request limits the amount of data
the kernel pushes to userpsace.

The feature exists in userspace already, so no need to warn the user
if kernel side support does not exist. Using the kernel side filter
makes the request more efficient.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Kernel support was just picked up, 16660f0bd942, so here is the ip
patch. This one depends on the earlier refactoring done for filtering
by master device.

 ip/ipneigh.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index b8973a2d0a08..ded514da642d 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -419,6 +419,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 			fprintf(stderr, "Cannot find device \"%s\"\n", filter_dev);
 			return -1;
 		}
+		addattr32(&req.n, sizeof(req), NDA_IFINDEX, filter.index);
 	}
 
 	if (flush) {
-- 
1.9.1
