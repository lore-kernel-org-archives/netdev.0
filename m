From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v3 2/2] add support for IFA_F_MANAGETEMPADDR
Date: Mon,  6 Jan 2014 10:17:10 +0100
Message-ID: <1388999830-1753-3-git-send-email-jiri@resnulli.us>
References: <1388999830-1753-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, thaller@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:47508 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbaAFJRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 04:17:18 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so6691301eek.27
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 01:17:17 -0800 (PST)
In-Reply-To: <1388999830-1753-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_addr.h |  1 +
 ip/ipaddress.c          | 11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index cced59f..e1e95ce 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -45,6 +45,7 @@ enum {
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
+#define IFA_F_MANAGETEMPADDR	0x0100
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1e3f22c..b0d54fe 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -82,7 +82,7 @@ static void usage(void)
 	fprintf(stderr, "           tentative | deprecated | dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
-	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
+	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 
@@ -703,6 +703,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		ifa_flags &= ~IFA_F_NODAD;
 		fprintf(fp, "nodad ");
 	}
+	if (ifa_flags & IFA_F_MANAGETEMPADDR) {
+		ifa_flags &= ~IFA_F_MANAGETEMPADDR;
+		fprintf(fp, "mngtmpaddr ");
+	}
 	if (!(ifa_flags & IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
@@ -1126,6 +1130,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "nodad") == 0) {
 			filter.flags |= IFA_F_NODAD;
 			filter.flagmask |= IFA_F_NODAD;
+		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
+			filter.flags |= IFA_F_MANAGETEMPADDR;
+			filter.flagmask |= IFA_F_MANAGETEMPADDR;
 		} else if (strcmp(*argv, "dadfailed") == 0) {
 			filter.flags |= IFA_F_DADFAILED;
 			filter.flagmask |= IFA_F_DADFAILED;
@@ -1345,6 +1352,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			ifa_flags |= IFA_F_HOMEADDRESS;
 		} else if (strcmp(*argv, "nodad") == 0) {
 			ifa_flags |= IFA_F_NODAD;
+		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
+			ifa_flags |= IFA_F_MANAGETEMPADDR;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
-- 
1.8.3.1
