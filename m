From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 7/7] [IP] XFRM: Mobility header support.
Date: Tue,  5 Dec 2006 19:16:12 +0900
Message-ID: <116531377212-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38936 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1759781AbWLEKQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:16:41 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipxfrm.c |    9 +++++++++
 ip/xfrm.h   |    3 +++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 7c9fd0b..9c8b4bd 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -483,6 +483,14 @@ void xfrm_selector_print(struct xfrm_sel
 		if (sel->dport_mask)
 			fprintf(fp, "code %u ", ntohs(sel->dport));
 		break;
+	case IPPROTO_MH:
+		if (sel->sport_mask)
+			fprintf(fp, "type %u ", ntohs(sel->sport));
+		if (sel->dport_mask) {
+			if (show_stats > 0)
+				fprintf(fp, "(dport) 0x%.4x ", sel->dport);
+		}
+		break;
 	}
 
 	if (sel->ifindex > 0) {
@@ -1111,6 +1119,7 @@ static int xfrm_selector_upspec_parse(st
 		switch (sel->proto) {
 		case IPPROTO_ICMP:
 		case IPPROTO_ICMPV6:
+		case IPPROTO_MH:
 			break;
 		default:
 			fprintf(stderr, "\"type\" and \"code\" are invalid with proto=%s\n", strxf_proto(sel->proto));
diff --git a/ip/xfrm.h b/ip/xfrm.h
index d33ff94..03db37b 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -35,6 +35,9 @@ #endif
 #ifndef IPPPROTO_DCCP
 # define IPPROTO_DCCP	33
 #endif
+#ifndef IPPROTO_MH
+# define IPPROTO_MH	135
+#endif
 
 #define XFRMS_RTA(x)  ((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_usersa_info))))
 #define XFRMS_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct xfrm_usersa_info))
-- 
1.4.2

