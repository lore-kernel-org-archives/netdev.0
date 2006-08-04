From: James Morris <jmorris@namei.org>
Subject: [Patch] fix potential stack overflow in net/core/utils.c (fwd)
Date: Thu, 3 Aug 2006 23:00:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608032300390.4343@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:34797 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030301AbWHDDAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 23:00:48 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail8.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 4 Aug 2006 03:00:47 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
Date: Thu, 3 Aug 2006 18:35:45 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
To: akpm@osdl.org
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org
Subject: [Patch] fix potential stack overflow in net/core/utils.c

On High end systems (1024 or so cpus) this can potentially cause stack
overflow. Fix the stack usage.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>

--- linux-2.6.18-rc3/net/core/utils.c~	2006-08-03 14:50:28.341080424 -0700
+++ linux-2.6.18-rc3/net/core/utils.c	2006-08-03 14:50:51.222601904 -0700
@@ -130,12 +130,13 @@ void __init net_random_init(void)
 static int net_random_reseed(void)
 {
 	int i;
-	unsigned long seed[NR_CPUS];
+	unsigned long seed;
 
-	get_random_bytes(seed, sizeof(seed));
 	for_each_possible_cpu(i) {
 		struct nrnd_state *state = &per_cpu(net_rand_state,i);
-		__net_srandom(state, seed[i]);
+
+		get_random_bytes(&seed, sizeof(seed));
+		__net_srandom(state, seed);
 	}
 	return 0;
 }
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
