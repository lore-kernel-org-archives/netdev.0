From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/8][BONDING]: Don't create bondings with % in their names.
Date: Tue, 29 Apr 2008 18:56:53 +0400
Message-ID: <48173735.5060505@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39458 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbYD2PBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:01:15 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Type 
# echo '+bond%d' > /sys/class/net/bonding_masters
and get the 'bond%d' device in the ip l l output.

Other drivers do not play such jokes on user :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 36121b6..2072910 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4909,6 +4909,10 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 		res = dev_alloc_name(bond_dev, "bond%d");
 		if (res < 0)
 			goto out_netdev;
+	} else if (strchr(name, '%')) {
+		res = dev_alloc_name(bond_dev, name);
+		if (res < 0)
+			goto out_netdev;
 	}
 
 	/* bond_init() must be called after dev_alloc_name() (for the
-- 
1.5.3.4

