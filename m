From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 11/15] ieee1394: eth1394: clean up
 fragment_overlap
Date: Mon, 2 Apr 2007 02:21:46 +0200 (CEST)
Message-ID: <tkrat.9c20fcc8c1af8a26@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:36729 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbXDBAVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2007 20:21:50 -0400
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

offset > fi->offset + fi->len - 1  ==  !(offset < fi->offset + fi->len)
offset + len - 1 < fi->offset      ==  !(offset + len > fi->offset)
!(A || B)  ==  (!A && !B)

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -871,12 +871,12 @@ static u16 ether1394_parse_encap(struct 
 static int fragment_overlap(struct list_head *frag_list, int offset, int len)
 {
 	struct fragment_info *fi;
+	int end = offset + len;
 
-	list_for_each_entry(fi, frag_list, list) {
-		if ( ! ((offset > (fi->offset + fi->len - 1)) ||
-		       ((offset + len - 1) < fi->offset)))
+	list_for_each_entry(fi, frag_list, list)
+		if (offset < fi->offset + fi->len && end > fi->offset)
 			return 1;
-	}
+
 	return 0;
 }
 

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/

