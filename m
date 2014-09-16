From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip tuntap: Add checking if tun/tap mode was set by default
Date: Tue, 16 Sep 2014 23:54:34 +0300
Message-ID: <1410900874-8317-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:44220 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbaIPVCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 17:02:51 -0400
Received: by mail-la0-f52.google.com with SMTP id gq15so613840lab.25
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 14:02:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This checking was performed only when adding interface but
it is needed also when deleting, otherwise the error will be:

    ioctl(TUNSETIFF): Invalid argument

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/iptuntap.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 2391af2..c6dacd7 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -186,6 +186,11 @@ static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_
 		argc--; argv++;
 	}
 
+	if (!(ifr->ifr_flags & TUN_TYPE_MASK)) {
+		fprintf(stderr, "You failed to specify a tunnel mode\n");
+		return -1;
+	}
+
 	return 0;
 }
 
@@ -199,10 +204,6 @@ static int do_add(int argc, char **argv)
 	if (parse_args(argc, argv, &ifr, &uid, &gid) < 0)
 		return -1;
 
-	if (!(ifr.ifr_flags & TUN_TYPE_MASK)) {
-		fprintf(stderr, "You failed to specify a tunnel mode\n");
-		return -1;
-	}
 	return tap_add_ioctl(&ifr, uid, gid);
 }
 
-- 
2.1.0
