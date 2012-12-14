From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH 08/12] bonding: do not cancel works in bond_uninit()
Date: Fri, 14 Dec 2012 15:02:55 +0400
Message-ID: <20121214110255.11019.14759.stgit@zurg>
References: <20121214110229.11019.63713.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121214110229.11019.63713.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bonding initializes these works in bond_open() and cancels in bond_close(),
thus in bond_uninit() they are already canceled but may be unitialized yet.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/bonding/bond_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ef2cb24..b7d45f3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4431,8 +4431,6 @@ static void bond_uninit(struct net_device *bond_dev)
 
 	list_del(&bond->bond_list);
 
-	bond_work_cancel_all(bond);
-
 	bond_debug_unregister(bond);
 
 	__hw_addr_flush(&bond->mc_list);
