From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] qeth: fix offset error in non prealloc header path
Date: Fri, 24 Oct 2008 11:16:53 +0200
Message-ID: <20081024091732.021609000@de.ibm.com>
References: <20081024091651.603673000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:60494 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbYJXJTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:19:04 -0400
Content-Disposition: inline; filename=603-qeth-offset.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

For the non preallocated qeth header code path we should not
change the header length.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: git_linus/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core_main.c
+++ git_linus/drivers/s390/net/qeth_core_main.c
@@ -3025,7 +3025,7 @@ static inline void __qeth_fill_buffer(st
 	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
 	int offset)
 {
-	int length = skb->len - offset;
+	int length = skb->len;
 	int length_here;
 	int element;
 	char *data;
@@ -3037,6 +3037,7 @@ static inline void __qeth_fill_buffer(st
 
 	if (offset >= 0) {
 		data = skb->data + offset;
+		length -= offset;
 		first_lap = 0;
 	}
 

-- 
