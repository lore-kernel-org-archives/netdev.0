From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 4/8] iproute2: Add address family to/from string helper functions.
Date: Fri, 13 Mar 2015 13:55:16 -0500
Message-ID: <87lhj0raln.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:35783 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbbCMS7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 14:59:01 -0400
In-Reply-To: <87bnjwspek.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 13:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add the functions family_name and read_family to convert an address
family to a string and to convernt a string to an address family.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/utils.h |  3 +++
 ip/ip.c         | 16 +++-------------
 lib/utils.c     | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 13 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index e1dd3f69165f..d96bd03dd816 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -106,6 +106,9 @@ extern const char *format_host(int af, int len, const void *addr,
 extern const char *rt_addr_n2a(int af, int len, const void *addr,
 			       char *buf, int buflen);
 
+extern int read_family(const char *name);
+extern const char *family_name(int family);
+
 void missarg(const char *) __attribute__((noreturn));
 void invarg(const char *, const char *) __attribute__((noreturn));
 void duparg(const char *, const char *) __attribute__((noreturn));
diff --git a/ip/ip.c b/ip/ip.c
index da16b15f8b55..85256d8ea0c1 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -190,21 +190,11 @@ int main(int argc, char **argv)
 			argv++;
 			if (argc <= 1)
 				usage();
-			if (strcmp(argv[1], "inet") == 0)
-				preferred_family = AF_INET;
-			else if (strcmp(argv[1], "inet6") == 0)
-				preferred_family = AF_INET6;
-			else if (strcmp(argv[1], "dnet") == 0)
-				preferred_family = AF_DECnet;
-			else if (strcmp(argv[1], "link") == 0)
-				preferred_family = AF_PACKET;
-			else if (strcmp(argv[1], "ipx") == 0)
-				preferred_family = AF_IPX;
-			else if (strcmp(argv[1], "bridge") == 0)
-				preferred_family = AF_BRIDGE;
-			else if (strcmp(argv[1], "help") == 0)
+			if (strcmp(argv[1], "help") == 0)
 				usage();
 			else
+				preferred_family = read_family(argv[1]);
+			if (preferred_family == AF_UNSPEC)
 				invarg("invalid protocol family", argv[1]);
 		} else if (strcmp(opt, "-4") == 0) {
 			preferred_family = AF_INET;
diff --git a/lib/utils.c b/lib/utils.c
index 65d1632ddbc1..b293407e550d 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -654,6 +654,41 @@ const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen
 	}
 }
 
+int read_family(const char *name)
+{
+	int family = AF_UNSPEC;
+	if (strcmp(name, "inet") == 0)
+		family = AF_INET;
+	else if (strcmp(name, "inet6") == 0)
+		family = AF_INET6;
+	else if (strcmp(name, "dnet") == 0)
+		family = AF_DECnet;
+	else if (strcmp(name, "link") == 0)
+		family = AF_PACKET;
+	else if (strcmp(name, "ipx") == 0)
+		family = AF_IPX;
+	else if (strcmp(name, "bridge") == 0)
+		family = AF_BRIDGE;
+	return family;
+}
+
+const char *family_name(int family)
+{
+	if (family == AF_INET)
+		return "inet";
+	if (family == AF_INET6)
+		return "inet6";
+	if (family == AF_DECnet)
+		return "dnet";
+	if (family == AF_PACKET)
+		return "link";
+	if (family == AF_IPX)
+		return "ipx";
+	if (family == AF_BRIDGE)
+		return "bridge";
+	return "???";
+}
+
 #ifdef RESOLVE_HOSTNAMES
 struct namerec
 {
-- 
2.2.1
