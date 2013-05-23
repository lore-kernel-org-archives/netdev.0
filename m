From: Sriram Narasimhan <sriram.narasimhan@hp.com>
Subject: [PATCH] iptuntap: allow creation of multi-queue tun/tap device
Date: Thu, 23 May 2013 15:36:29 -0700
Message-ID: <1369348589-38730-1-git-send-email-sriram.narasimhan@hp.com>
Cc: Sriram Narasimhan <sriram.narasimhan@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:22619 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759752Ab3EWWnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 18:43:31 -0400
Received: from g5t0029.atlanta.hp.com (g5t0029.atlanta.hp.com [16.228.8.141])
	by g5t0006.atlanta.hp.com (Postfix) with ESMTP id BDF05C41E
	for <netdev@vger.kernel.org>; Thu, 23 May 2013 22:43:30 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds multi_queue option to ip tuntap.
This allows IFF_MULTI_QUEUE flag to be specified during
tun/tap device creation enabling multi-queue support in tun/tap
device.

Example: ip tuntap add dev tap0 mode tap multi_queue

Signed-off-by: Sriram Narasimhan <sriram.narasimhan@hp.com>
---
 ip/iptuntap.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 3d9ad7d..2391af2 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -38,7 +38,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
 	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
-	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ]\n");
+	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: USER  := { STRING | NUMBER }\n");
 	fprintf(stderr, "       GROUP := { STRING | NUMBER }\n");
@@ -168,6 +168,8 @@ static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_
 			ifr->ifr_flags |= IFF_ONE_QUEUE;
 		} else if (matches(*argv, "vnet_hdr") == 0) {
 			ifr->ifr_flags |= IFF_VNET_HDR;
+		} else if (matches(*argv, "multi_queue") == 0) {
+			ifr->ifr_flags |= IFF_MULTI_QUEUE;
 		} else if (matches(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(ifr->ifr_name, *argv, IFNAMSIZ-1);
-- 
1.7.1
