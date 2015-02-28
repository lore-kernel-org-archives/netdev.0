From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip tap: Simplify add 'tap' device w/o mode
Date: Sat, 28 Feb 2015 11:59:46 +0200
Message-ID: <1425117586-21461-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:34748 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbB1KLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 05:11:10 -0500
Received: by labhs14 with SMTP id hs14so21948395lab.1
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 02:11:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

It allows add 'tap' device w/o specify mode:

    # ip tap add tap0

instead of return error message.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/iptuntap.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index b9b28a1..61b6c19 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -107,6 +107,7 @@ static int tap_del_ioctl(struct ifreq *ifr)
 static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_t *gid)
 {
 	int count = 0;
+	char *cmd = *(argv - 2);
 
 	memset(ifr, 0, sizeof(*ifr));
 
@@ -187,8 +188,12 @@ static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_
 	}
 
 	if (!(ifr->ifr_flags & TUN_TYPE_MASK)) {
-		fprintf(stderr, "You failed to specify a tunnel mode\n");
-		return -1;
+		if(strncmp("tap", cmd, 3) == 0) {
+			ifr->ifr_flags |= IFF_TAP;
+		} else {
+			fprintf(stderr, "You failed to specify a tunnel mode\n");
+			return -1;
+		}
 	}
 
 	return 0;
-- 
2.2.2
