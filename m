From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/8][BONDING]: Merge two calls to dev_alloc_name.
Date: Tue, 29 Apr 2008 18:58:37 +0400
Message-ID: <4817379D.8040409@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58846 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbYD2PMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:12:14 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just reduce the amount of code after the previous patch.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2072910..0907f43 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4905,11 +4905,10 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 		goto out_rtnl;
 	}
 
-	if (!name) {
-		res = dev_alloc_name(bond_dev, "bond%d");
-		if (res < 0)
-			goto out_netdev;
-	} else if (strchr(name, '%')) {
+	if (!name)
+		name = "bond%d";
+
+	if (strchr(name, '%')) {
 		res = dev_alloc_name(bond_dev, name);
 		if (res < 0)
 			goto out_netdev;
-- 
1.5.3.4


