From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH iproute2] bridge: Assume master at FDB modification
Date: Wed, 26 Jul 2017 18:36:34 +0300
Message-ID: <1501083394-26180-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51574 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750898AbdGZPd1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 11:33:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the man page the master flag should be the default, yet, the
current code assumes otherwise.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 bridge/fdb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index e5cebf9..7c77157 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -496,9 +496,9 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
-	/* Assume self */
+	/* Assume master */
 	if (!(req.ndm.ndm_flags&(NTF_SELF|NTF_MASTER)))
-		req.ndm.ndm_flags |= NTF_SELF;
+		req.ndm.ndm_flags |= NTF_MASTER;
 
 	/* Assume permanent */
 	if (!(req.ndm.ndm_state&(NUD_PERMANENT|NUD_REACHABLE)))
-- 
2.4.11
