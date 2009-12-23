From: Dan Carpenter <error27@gmail.com>
Subject: [patch] bond_3ad.c avoid possible null deref
Date: Wed, 23 Dec 2009 15:27:10 +0200
Message-ID: <20091223132710.GE17923@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f211.google.com ([209.85.217.211]:43102 "EHLO
	mail-gx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854AbZLWN1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 08:27:39 -0500
Received: by gxk3 with SMTP id 3so1373414gxk.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 05:27:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few lines earlier we assume that best->slave could be either null or non-null so 
we should check it here as well.

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/bonding/bond_3ad.c	2009-12-23 00:06:58.000000000 +0200
+++ devel/drivers/net/bonding/bond_3ad.c	2009-12-23 00:07:31.000000000 +0200
@@ -1580,7 +1580,7 @@ static void ad_agg_selection_logic(struc
 		// check if any partner replys
 		if (best->is_individual) {
 			pr_warning("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
-				   best->slave->dev->master->name);
+				   best->slave ? best->slave->dev->master->name : "NULL");
 		}
 
 		best->is_active = 1;
