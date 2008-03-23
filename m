From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] NET: Use shorter list_splice_init() macro for brevity.
Date: Sun, 23 Mar 2008 10:13:48 -0400 (EDT)
Message-ID: <alpine.LFD.1.00.0803231012460.11270@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:53898 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759085AbYCWONw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 10:13:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 14299f8..93e1363 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -532,8 +532,7 @@ static void cas_spare_free(struct cas *cp)
 	/* free spare buffers */
 	INIT_LIST_HEAD(&list);
 	spin_lock(&cp->rx_spare_lock);
-	list_splice(&cp->rx_spare_list, &list);
-	INIT_LIST_HEAD(&cp->rx_spare_list);
+	list_splice_init(&cp->rx_spare_list, &list);
 	spin_unlock(&cp->rx_spare_lock);
 	list_for_each_safe(elem, tmp, &list) {
 		cas_page_free(cp, list_entry(elem, cas_page_t, list));
@@ -546,13 +545,11 @@ static void cas_spare_free(struct cas *cp)
 	 * lock than used everywhere else to manipulate this list.
 	 */
 	spin_lock(&cp->rx_inuse_lock);
-	list_splice(&cp->rx_inuse_list, &list);
-	INIT_LIST_HEAD(&cp->rx_inuse_list);
+	list_splice_init(&cp->rx_inuse_list, &list);
 	spin_unlock(&cp->rx_inuse_lock);
 #else
 	spin_lock(&cp->rx_spare_lock);
-	list_splice(&cp->rx_inuse_list, &list);
-	INIT_LIST_HEAD(&cp->rx_inuse_list);
+	list_splice_init(&cp->rx_inuse_list, &list);
 	spin_unlock(&cp->rx_spare_lock);
 #endif
 	list_for_each_safe(elem, tmp, &list) {
@@ -573,8 +570,7 @@ static void cas_spare_recover(struct cas *cp, const gfp_t flags)
 	/* make a local copy of the list */
 	INIT_LIST_HEAD(&list);
 	spin_lock(&cp->rx_inuse_lock);
-	list_splice(&cp->rx_inuse_list, &list);
-	INIT_LIST_HEAD(&cp->rx_inuse_list);
+	list_splice_init(&cp->rx_inuse_list, &list);
 	spin_unlock(&cp->rx_inuse_lock);

 	list_for_each_safe(elem, tmp, &list) {

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
