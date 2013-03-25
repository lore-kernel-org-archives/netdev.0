From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 2/7] ip/xfrm: Do not allow redundant algorithm combinations to be specified
Date: Mon, 25 Mar 2013 10:23:14 -0400
Message-ID: <1364221399-1024-2-git-send-email-david.ward@ll.mit.edu>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42068 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758128Ab3CYOX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:28 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEN2ct023593 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:28 -0400
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AEAD algorithms perform both encryption and authentication; they are
not combined with separate encryption or authentication algorithms.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/xfrm_state.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 3c01ec5..85d3e35 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -379,18 +379,18 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 
 				switch (type) {
 				case XFRMA_ALG_AEAD:
-					if (aeadop)
+					if (ealgop || aalgop || aeadop)
 						duparg("ALGO-TYPE", *argv);
 					aeadop = *argv;
 					break;
 				case XFRMA_ALG_CRYPT:
-					if (ealgop)
+					if (ealgop || aeadop)
 						duparg("ALGO-TYPE", *argv);
 					ealgop = *argv;
 					break;
 				case XFRMA_ALG_AUTH:
 				case XFRMA_ALG_AUTH_TRUNC:
-					if (aalgop)
+					if (aalgop || aeadop)
 						duparg("ALGO-TYPE", *argv);
 					aalgop = *argv;
 					break;
-- 
1.7.1
