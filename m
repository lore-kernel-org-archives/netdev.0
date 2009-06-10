From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH] net: no need check in tehuti.c
Date: Wed, 10 Jun 2009 22:18:38 +0800
Message-ID: <1244643518.3422.6.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:25874 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbZFJOSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:18:39 -0400
Received: by rv-out-0506.google.com with SMTP id f9so267355rvb.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 07:18:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vfree() does its own 'NULL' check, so no need for check before
calling it.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---   
drivers/net/tehuti.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 7f4a968..430f2af 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -948,8 +948,7 @@ static void print_rxfd(struct rxf_desc *rxfd);
 
 static void bdx_rxdb_destroy(struct rxdb *db)
 {
-	if (db)
-		vfree(db);
+	vfree(db);
 }
 
 static struct rxdb *bdx_rxdb_create(int nelem)
@@ -1482,10 +1481,8 @@ static void bdx_tx_db_close(struct txdb *d)
 {
 	BDX_ASSERT(d == NULL);
 
-	if (d->start) {
-		vfree(d->start);
-		d->start = NULL;
-	}
+	vfree(d->start);
+	d->start = NULL;
 }
 
 /*************************************************************************


