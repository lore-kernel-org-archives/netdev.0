From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: fix multiple module load problem
Date: Tue, 9 Jun 2009 10:23:29 -0700
Message-ID: <20090609102329.565e9019@nehalam>
References: <20090608151127.70146505@nehalam>
	<200906091406.45463.arnd@arndb.de>
	<20090609080232.45f81833@nehalam>
	<4A2E80B3.6010600@trash.net>
	<4752.1244564082@death.nxdomain.ibm.com>
	<4A2E8D62.6090004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50309 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945AbZFIRXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 13:23:34 -0400
In-Reply-To: <4A2E8D62.6090004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some users still load bond module multiple times to create bonding
devices.  This accidentally was broken when sysfs interface was added.

Note: sysfs and procfs still produce WARN() messages when this is done
so the sysfs method is the recommended API.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against 2.6.30-rc8

--- a/drivers/net/bonding/bond_sysfs.c	2009-06-09 10:07:29.618979856 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-09 10:18:04.039973238 -0700
@@ -1538,6 +1538,7 @@ int bond_create_sysfs(void)
 			printk(KERN_ERR
 			       "network device named %s already exists in sysfs",
 			       class_attr_bonding_masters.attr.name);
+		ret = 0;
 	}
 
 	return ret;
