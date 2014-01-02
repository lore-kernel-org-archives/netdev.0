From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 2/2] add support for IFA_F_MANAGETEMPADDR
Date: Thu,  2 Jan 2014 16:34:39 +0100
Message-ID: <1388676879-2603-3-git-send-email-jiri@resnulli.us>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, thaller@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:41519 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbaABPet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 10:34:49 -0500
Received: by mail-ea0-f178.google.com with SMTP id d10so6480464eaj.9
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 07:34:48 -0800 (PST)
In-Reply-To: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_addr.h | 1 +
 ip/ipaddress.c          | 6 ++++++
 2 files changed, 7 insertions(+)

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
index 1e3f22c..5dbb017 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
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
@@ -1345,6 +1349,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
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
