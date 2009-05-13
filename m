From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/8] gigaset: skip unnecessary hex formatting
Date: Thu, 14 May 2009 00:44:17 +0200 (CEST)
Message-ID: <20090514-patch-04.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:38987 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760772AbZEMWoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:37 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't generate the hex representation of the payload data if it
isn't actually used afterwards.

Impact: optimization
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/isocdata.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index b171e75..09202a5 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -246,6 +246,10 @@ static inline void dump_bytes(enum debuglevel level, const char *tag,
 	unsigned char c;
 	static char dbgline[3 * 32 + 1];
 	int i = 0;
+
+	if (!(gigaset_debuglevel & level))
+		return;
+
 	while (count-- > 0) {
 		if (i > sizeof(dbgline) - 4) {
 			dbgline[i] = '\0';
-- 
1.6.2.1.214.ge986c

