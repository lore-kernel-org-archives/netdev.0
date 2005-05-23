From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding using arp_ip_target may stay down with active path
Date: Mon, 23 May 2005 14:21:36 -0700
Message-ID: <200505232121.j4NLLaYa000837@death.nxdomain.ibm.com>
References: <davem@davemloft.net>
Cc: eparis@parisplace.org, netdev@oss.sgi.com, jgarzik@pobox.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: Message from "David S. Miller" <davem@davemloft.net>
   of "Mon, 23 May 2005 12:51:07 PDT." <20050523.125107.45741257.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller <davem@davemloft.net> wrote:
>Patch doesn't apply, tabs turned into spaces by your
>email client.

	As penance for test applying trivial patches by hand, here's a
proper version.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff -urN linux-2.6.11/drivers/net/bonding/bond_main.c linux-2.6.11-fix/drivers/net/bonding/bond_main.c
--- linux-2.6.11/drivers/net/bonding/bond_main.c	2005-05-23 14:07:37.000000000 -0700
+++ linux-2.6.11-fix/drivers/net/bonding/bond_main.c	2005-05-23 14:08:13.000000000 -0700
@@ -3046,7 +3046,7 @@
 			bond_set_slave_inactive_flags(bond->current_arp_slave);
 
 			/* search for next candidate */
-			bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave) {
+			bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
 				if (IS_UP(slave->dev)) {
 					slave->link = BOND_LINK_BACK;
 					bond_set_slave_active_flags(slave);
