From: Adam Borowski <kilobyte@angband.pl>
Subject: [PATCH] ip: fix build failure if time_t is not long int
Date: Tue, 25 Jun 2013 01:39:21 +0200
Message-ID: <E1UrGdI-0002et-AY@tartarus.angband.pl>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tartarus.angband.pl ([89.206.35.136]:33092 "EHLO
	tartarus.angband.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab3FYAlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 20:41:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes x32, and, per Linus' decree, any future arch with longs
shorter than 64 bits.

Signed-off-by: Adam Borowski <kilobyte@angband.pl>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index adef774..d3c56d3 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1330,7 +1330,7 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 
 			if (time(0) - start > 30) {
 				printf("\n*** Flush not completed after %ld seconds, %d entries remain ***\n",
-				       time(0) - start, filter.flushed);
+				       (long)(time(0) - start), filter.flushed);
 				exit(1);
 			}
 
-- 
1.8.3.1
