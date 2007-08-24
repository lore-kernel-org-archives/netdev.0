From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH 16/30] net: Avoid pointless allocation casts in BSD compression module
Date: Fri, 24 Aug 2007 02:06:58 +0200
Message-ID: <fd58f69b12c07872b351261199f3c677c6786f06.1187912217.git.jesper.juhl@gmail.com>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesper Juhl <jesper.juhl@gmail.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:60633 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636AbXHXAJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 20:09:50 -0400
Received: by mu-out-0910.google.com with SMTP id i10so901551mue
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 17:09:49 -0700 (PDT)
In-Reply-To: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The general kernel memory allocation functions return void pointers
and there is no need to cast their return values.

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---
 drivers/net/bsd_comp.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bsd_comp.c b/drivers/net/bsd_comp.c
index 202d4a4..88edb98 100644
--- a/drivers/net/bsd_comp.c
+++ b/drivers/net/bsd_comp.c
@@ -406,8 +406,7 @@ static void *bsd_alloc (unsigned char *options, int opt_len, int decomp)
  * Allocate space for the dictionary. This may be more than one page in
  * length.
  */
-    db->dict = (struct bsd_dict *) vmalloc (hsize *
-					    sizeof (struct bsd_dict));
+    db->dict = vmalloc(hsize * sizeof(struct bsd_dict));
     if (!db->dict)
       {
 	bsd_free (db);
@@ -426,8 +425,7 @@ static void *bsd_alloc (unsigned char *options, int opt_len, int decomp)
  */
     else
       {
-        db->lens = (unsigned short *) vmalloc ((maxmaxcode + 1) *
-					       sizeof (db->lens[0]));
+        db->lens = vmalloc((maxmaxcode + 1) * sizeof(db->lens[0]));
 	if (!db->lens)
 	  {
 	    bsd_free (db);
-- 
1.5.2.2

