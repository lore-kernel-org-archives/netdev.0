From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] iproute2: add support of flag XFRM_STATE_ALIGN4
Date: Wed, 02 Mar 2011 19:08:47 +0100
Message-ID: <4D6E87AF.8090204@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090703030206000406070104"
To: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35025 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310Ab1CBSIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:08:51 -0500
Received: by wyg36 with SMTP id 36so256934wyg.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 10:08:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090703030206000406070104
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

please find the patch enclosed.


Regards,
Nicolas

--------------090703030206000406070104
Content-Type: text/x-patch;
 name="0001-iproute2-add-support-of-flag-XFRM_STATE_ALIGN4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-iproute2-add-support-of-flag-XFRM_STATE_ALIGN4.patch"

>From 61fafffaa53ac1bcf1a2a93e6637517c4eb2ac93 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 1 Feb 2011 07:29:54 -0500
Subject: [PATCH] iproute2: add support of flag XFRM_STATE_ALIGN4

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipxfrm.c     |    1 +
 ip/xfrm_state.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index a276c0b..0c7aaad 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -854,6 +854,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_WILDRECV, "wildrecv");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ICMP, "icmp");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_AF_UNSPEC, "af-unspec");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ALIGN4, "align4");
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 94acd66..8ac3437 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -84,7 +84,7 @@ static void usage(void)
  	//fprintf(stderr, "REQID - number(default=0)\n");
 
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec ]\n");
+	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4 ]\n");
 
         fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
@@ -216,6 +216,8 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 				*flags |= XFRM_STATE_ICMP;
 			else if (strcmp(*argv, "af-unspec") == 0)
 				*flags |= XFRM_STATE_AF_UNSPEC;
+			else if (strcmp(*argv, "align4") == 0)
+				*flags |= XFRM_STATE_ALIGN4;
 			else {
 				PREV_ARG(); /* back track */
 				break;
-- 
1.5.6.5


--------------090703030206000406070104--
