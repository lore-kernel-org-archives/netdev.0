From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] gtp: Use kmalloc_array() in gtp_hashtable_new()
Date: Thu, 26 Jan 2017 11:17:05 +0100
Message-ID: <b723e4d3-222b-6dd1-0223-2398536e4d1c@users.sourceforge.net>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:63888 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751899AbdAZKRn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 05:17:43 -0500
In-Reply-To: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 25 Jan 2017 22:01:00 +0100

* Multiplications for the size determination of memory allocations
  indicated that array data structures should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of data structures by pointer dereferences
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/gtp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8b6810bad54b..5d0d520ae40f 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -783,11 +783,13 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 {
 	int i;
 
-	gtp->addr_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
+	gtp->addr_hash = kmalloc_array(hsize, sizeof(*gtp->addr_hash),
+				       GFP_KERNEL);
 	if (gtp->addr_hash == NULL)
 		return -ENOMEM;
 
-	gtp->tid_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
+	gtp->tid_hash = kmalloc_array(hsize, sizeof(*gtp->tid_hash),
+				      GFP_KERNEL);
 	if (gtp->tid_hash == NULL)
 		goto err1;
 
-- 
2.11.0
