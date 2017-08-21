From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/7] ss: Make sure scanned index value to unix_state_map is sane
Date: Mon, 21 Aug 2017 19:08:09 +0200
Message-ID: <20170821170813.29697-4-phil@nwl.cc>
References: <20170821170813.29697-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36951 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753830AbdHURIu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:08:50 -0400
In-Reply-To: <20170821170813.29697-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 1ee02d73b2d7f..6c091a694231e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3151,7 +3151,8 @@ static int unix_show(struct filter *f)
 
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
