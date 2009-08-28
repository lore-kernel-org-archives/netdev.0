From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] pktgen: use proc_create_data()
Date: Fri, 28 Aug 2009 23:47:21 +0400
Message-ID: <20090828194721.GD14499@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:44313 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbZH1TrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:47:25 -0400
Received: by ewy2 with SMTP id 2so2430056ewy.17
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 12:47:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like after rename device proc entry is unusable,
because of no ->read_proc or ->proc_fops.

And create_proc_entry() is deprecated.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/pktgen.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1873,8 +1873,10 @@ static void pktgen_change_name(struct net_device *dev)
 
 			remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
 
-			pkt_dev->entry = create_proc_entry(dev->name, 0600,
-							   pg_proc_dir);
+			pkt_dev->entry = proc_create_data(dev->name, 0600,
+							  pg_proc_dir,
+							  &pktgen_if_fops,
+							  pkt_dev);
 			if (!pkt_dev->entry)
 				printk(KERN_ERR "pktgen: can't move proc "
 				       " entry for '%s'\n", dev->name);
