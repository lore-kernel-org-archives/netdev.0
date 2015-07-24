From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH] ip/ip6tunnel: fix missing return value check
Date: Fri, 24 Jul 2015 12:11:32 -0400
Message-ID: <1437754292-8279-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3355 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbbGXQLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 12:11:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that return value of each socket() call is properly checked
and do not continue processing if the call failed.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/tunnel.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/ip/tunnel.c b/ip/tunnel.c
index 33c78e3..d69fe84 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -73,7 +73,13 @@ int tnl_get_ioctl(const char *basedev, void *p)
 
 	strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
 	ifr.ifr_ifru.ifru_data = (void*)p;
+
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "create socket failed: %s\n", strerror(errno));
+		return -1;
+	}
+
 	err = ioctl(fd, SIOCGETTUNNEL, &ifr);
 	if (err)
 		fprintf(stderr, "get tunnel \"%s\" failed: %s\n", basedev,
@@ -94,7 +100,13 @@ int tnl_add_ioctl(int cmd, const char *basedev, const char *name, void *p)
 	else
 		strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
 	ifr.ifr_ifru.ifru_data = p;
+
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "create socket failed: %s\n", strerror(errno));
+		return -1;
+	}
+
 	err = ioctl(fd, cmd, &ifr);
 	if (err)
 		fprintf(stderr, "add tunnel \"%s\" failed: %s\n", ifr.ifr_name,
@@ -115,7 +127,13 @@ int tnl_del_ioctl(const char *basedev, const char *name, void *p)
 		strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
 
 	ifr.ifr_ifru.ifru_data = p;
+
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "create socket failed: %s\n", strerror(errno));
+		return -1;
+	}
+
 	err = ioctl(fd, SIOCDELTUNNEL, &ifr);
 	if (err)
 		fprintf(stderr, "delete tunnel \"%s\" failed: %s\n",
@@ -133,7 +151,13 @@ static int tnl_gen_ioctl(int cmd, const char *name,
 
 	strncpy(ifr.ifr_name, name, IFNAMSIZ);
 	ifr.ifr_ifru.ifru_data = p;
+
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "create socket failed: %s\n", strerror(errno));
+		return -1;
+	}
+
 	err = ioctl(fd, cmd, &ifr);
 	if (err && errno != skiperr)
 		fprintf(stderr, "%s: ioctl %x failed: %s\n", name,
-- 
1.8.3.1
