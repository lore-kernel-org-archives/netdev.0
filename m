From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] hsr: off by one sanity check in hsr_register_frame_in()
Date: Sat, 1 Mar 2014 02:18:57 +0300
Message-ID: <20140228231857.GD22115@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23459 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaB1XTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 18:19:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a sanity check and we never pass invalid values so this patch
doesn't change anything.  However the node->time_in[] array has
HSR_MAX_SLAVE (2) elements and not HSR_MAX_DEV (3).

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 3d0100f0bae3..83e58449366a 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -297,7 +297,7 @@ static bool seq_nr_after(u16 a, u16 b)
 
 void hsr_register_frame_in(struct node_entry *node, enum hsr_dev_idx dev_idx)
 {
-	if ((dev_idx < 0) || (dev_idx >= HSR_MAX_DEV)) {
+	if ((dev_idx < 0) || (dev_idx >= HSR_MAX_SLAVE)) {
 		WARN_ONCE(1, "%s: Invalid dev_idx (%d)\n", __func__, dev_idx);
 		return;
 	}
