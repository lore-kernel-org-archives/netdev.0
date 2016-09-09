From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH] macsec: fix input range of 'icvlen' parameter
Date: Fri,  9 Sep 2016 16:02:22 +0200
Message-ID: <b1f730436465e511edb56e4486299e4f3835599b.1473428548.git.dcaratti@redhat.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>, Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750940AbcIIOCa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 10:02:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the maximum possible ICV length in a MACsec frame is 16 octects, not 32:
fix get_icvlen() accordingly, so that a proper error message is displayed
in case input 'icvlen' is greater than 16.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 ip/ipmacsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index 2e670e9..127fa1e 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -152,9 +152,9 @@ static void get_icvlen(__u8 *icvlen, char *arg)
 	if (ret)
 		invarg("expected ICV length", arg);
 
-	if (*icvlen < MACSEC_MIN_ICV_LEN || *icvlen > MACSEC_MAX_ICV_LEN)
+	if (*icvlen < MACSEC_MIN_ICV_LEN || *icvlen > MACSEC_STD_ICV_LEN)
 		invarg("ICV length must be in the range {"
-		       STR(MACSEC_MIN_ICV_LEN) ".." STR(MACSEC_MAX_ICV_LEN)
+		       STR(MACSEC_MIN_ICV_LEN) ".." STR(MACSEC_STD_ICV_LEN)
 		       "}", arg);
 }
 
-- 
2.5.5
