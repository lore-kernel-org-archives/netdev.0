From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 7)
Date: Fri, 12 Jun 2009 17:34:37 +0200
Message-ID: <4A32758D.6090506@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080407010100050109070707"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47625 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbZFLPej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 11:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080407010100050109070707
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080407010100050109070707
Content-Type: text/x-patch;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="07.diff"

commit 356695e6aa6fa75b4f48b05d22dcad264603abe4
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 17:32:06 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 7)
    
    Fix up ATM drivers that return an errno value to qdisc_restart(), causing
    qdisc_restart() to print a warning an requeue/retransmit the skb.
    
    - lec: condition can only be remedied by userspace, until that retransmissions
    
    Compile tested only.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 199b6bb..b499af4 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -271,7 +271,8 @@ static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk("%s:No lecd attached\n", dev->name);
 		dev->stats.tx_errors++;
 		netif_stop_queue(dev);
-		return -EUNATCH;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 
 	pr_debug("skbuff head:%lx data:%lx tail:%lx end:%lx\n",

--------------080407010100050109070707--
