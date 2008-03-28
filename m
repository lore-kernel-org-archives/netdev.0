From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] drivers/net/bonding/bond_sysfs.c: suppress
 uninitialized var warning
Date: Fri, 28 Mar 2008 16:16:07 -0700 (PDT)
Message-ID: <20080328.161607.259609373.davem@davemloft.net>
References: <200803282137.m2SLbUn3011629@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753087AbYC1XQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:16:07 -0400
In-Reply-To: <200803282137.m2SLbUn3011629@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 14:37:30 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/bonding/bond_sysfs.c: In function `bonding_store_slaves':
> drivers/net/bonding/bond_sysfs.c:250: warning: 'original_mtu' might be used uninitialized in this function
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Barf!

I'll fix it like this:

commit 6952d8923bcc8d6b8b43b065cfe9a31bb24f0d58
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Mar 28 16:15:38 2008 -0700

    [BOND]: Fix warning in bond_sysfs.c
    
    original_mtu is only used if we end up with a non-NULL
    dev, and it is assigned in all such cases, but GCC can't
    see that.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 90a1f31..979c2d0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -341,6 +341,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	if (command[0] == '-') {
 		dev = NULL;
+		original_mtu = 0;
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				dev = slave->dev;
