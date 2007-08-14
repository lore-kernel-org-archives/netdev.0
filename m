From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: BUG: when using 'brctl stp'
Date: Tue, 14 Aug 2007 14:11:05 +0100
Message-ID: <20070814141105.0a4b8dde@oldman.hamilton.local>
References: <46BCE380.60508@cluded.net>
	<20070812012037.0195b610.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39382 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750712AbXHNNLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 09:11:04 -0400
In-Reply-To: <20070812012037.0195b610.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bridge locking for /sys/class/net/br0/bridge/stp_enabled
was wrong.  Another bug in bridge utilities makes it such that
this interface, meant it wasn't being used.  The locking needs to be removed
from set_stp_state(), the lock is already acquired down in
br_stp_start()/br_stp_stop.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/net/bridge/br_sysfs_br.c	2007-07-16 14:24:18.000000000 +0100
+++ b/net/bridge/br_sysfs_br.c	2007-08-14 13:44:23.000000000 +0100
@@ -150,9 +150,7 @@ static ssize_t show_stp_state(struct dev
 static void set_stp_state(struct net_bridge *br, unsigned long val)
 {
 	rtnl_lock();
-	spin_unlock_bh(&br->lock);
 	br_stp_set_enabled(br, val);
-	spin_lock_bh(&br->lock);
 	rtnl_unlock();
 }
 
