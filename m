From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] ip link: Remove unnecessary device checking
Date: Sat, 30 Aug 2014 15:06:00 +0300
Message-ID: <1409400360-31612-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:61413 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbaH3MOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 08:14:23 -0400
Received: by mail-la0-f43.google.com with SMTP id ty20so4003811lab.16
        for <netdev@vger.kernel.org>; Sat, 30 Aug 2014 05:14:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The real checking is performed later in iplink_modify(..) func which
checks device existence if NLM_F_CREATE flag is set.

Also it fixes the case when impossible to add veth link which was
caused by 9a02651a87 (ip: check for missing dev arg when doing VF rate)
because these devices are not exist yet.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/iplink.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 1a907d9..ea06871 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -593,8 +593,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				duparg2("dev", *argv);
 			*dev = *argv;
 			dev_index = ll_name_to_index(*dev);
-			if (dev_index == 0)
-				invarg("Unknown device", *argv);
 		}
 		argc--; argv++;
 	}
-- 
2.1.0
