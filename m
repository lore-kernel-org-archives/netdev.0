From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 6/7] misc/ifstat: simplify unsigned value comparison
Date: Tue, 21 Jun 2016 18:18:40 +0200
Message-ID: <1466525921-15738-7-git-send-email-phil@nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53773 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbcFUQ1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 12:27:39 -0400
In-Reply-To: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By directly comparing the value of both unsigned variables, casting to
signed becomes unnecessary.

This also fixes for compiling with older versions of gcc (at least
<=3.4.6) which emit the following warning:

| ifstat.c: In function `update_db':
| ifstat.c:542: warning: comparison is always false due to limited range of data type

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ifstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index abbb4e732fcef..9a44da487599e 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -539,7 +539,7 @@ static void update_db(int interval)
 				int i;
 
 				for (i = 0; i < MAXS; i++) {
-					if ((long)(h1->ival[i] - n->ival[i]) < 0) {
+					if (h1->ival[i] < n->ival[i]) {
 						memset(n->ival, 0, sizeof(n->ival));
 						break;
 					}
-- 
2.8.2
