From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] iproute2: display xfrm socket policy direction
Date: Mon, 13 Sep 2010 15:29:05 +0200
Message-ID: <20100913132905.GA8366@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-67.dex002.intermedia.net ([64.78.20.25]:13136 "EHLO
	DHOST002-67.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751353Ab0IMN3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 09:29:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


display socket policy direction

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 ip/ipxfrm.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 78e1926..b3ff20b 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -861,7 +861,13 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 	STRBUF_CAT(buf, "\t");
 
 	fputs(buf, fp);
-	fprintf(fp, "dir ");
+	if (xpinfo->dir >= XFRM_POLICY_MAX) {
+		xpinfo->dir -= XFRM_POLICY_MAX;
+		fprintf(fp, "socket "); 
+	}
+	else
+		fprintf(fp, "dir ");
+
 	switch (xpinfo->dir) {
 	case XFRM_POLICY_IN:
 		fprintf(fp, "in");
-- 
1.7.0.4

