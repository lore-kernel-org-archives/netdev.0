From: Dan Carpenter <error27@gmail.com>
Subject: [patch] locking typo in xfrm_state.c
Date: Wed, 8 Apr 2009 13:45:48 +0300 (EAT)
Message-ID: <alpine.DEB.2.00.0904081345430.30705@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:36065 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbZDHKuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 06:50:00 -0400
Received: by yw-out-2324.google.com with SMTP id 5so44503ywb.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 03:49:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure who to send this patch to.

There is a double lock instead of an unlock.

Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.

regards,
dan carpenter

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/net/xfrm/xfrm_state.c	2009-04-08 09:19:10.000000000 +0300
+++ devel/net/xfrm/xfrm_state.c	2009-04-08 09:19:18.000000000 +0300
@@ -1615,7 +1615,7 @@
 
 	spin_lock_bh(&xfrm_state_lock);
 	list_del(&walk->all);
-	spin_lock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
 
