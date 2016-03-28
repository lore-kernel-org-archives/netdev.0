From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: fix a problem with netlbl_secattr_catmap_setrng()
Date: Mon, 28 Mar 2016 11:10:38 -0400
Message-ID: <145917783800.9565.7759086668991534988.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Janak Desai <Janak.Desai@gtri.gatech.edu>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370AbcC1PKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 11:10:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Janak Desai <Janak.Desai@gtri.gatech.edu>

We try to be clever and set large chunks of the bitmap at once, when
possible; unfortunately we weren't very clever when we wrote the code
and messed up the if-conditional.  Fix this bug and restore proper
operation.

Signed-off-by: Janak Desai <Janak.Desai@gtri.gatech.edu>
Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/netlabel/netlabel_kapi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 28cddc8..1325776 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -677,7 +677,7 @@ int netlbl_catmap_setrng(struct netlbl_lsm_catmap **catmap,
 	u32 spot = start;
 
 	while (rc == 0 && spot <= end) {
-		if (((spot & (BITS_PER_LONG - 1)) != 0) &&
+		if (((spot & (BITS_PER_LONG - 1)) == 0) &&
 		    ((end - spot) > BITS_PER_LONG)) {
 			rc = netlbl_catmap_setlong(catmap,
 						   spot,
