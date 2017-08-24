From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 2/6] ss: Make sure scanned index value to unix_state_map is sane
Date: Thu, 24 Aug 2017 11:41:27 +0200
Message-ID: <20170824094131.2963-3-phil@nwl.cc>
References: <20170824094131.2963-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51231 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752260AbdHXJmC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:42:02 -0400
In-Reply-To: <20170824094131.2963-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index c41d5169aba52..951aa877bcb01 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3148,7 +3148,8 @@ static int unix_show(struct filter *f)
 
 		if (flags & (1 << 16)) {
 			u->state = SS_LISTEN;
-		} else {
+		} else if (u->state > 0 &&
+			   u->state <= ARRAY_SIZE(unix_state_map)) {
 			u->state = unix_state_map[u->state-1];
 			if (u->type == SOCK_DGRAM && u->state == SS_CLOSE && u->rport)
 				u->state = SS_ESTABLISHED;
-- 
2.13.1
