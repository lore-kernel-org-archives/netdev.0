From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH] bonding using arp_ip_target may stay down with active
	path
Date: Tue, 24 May 2005 14:26:40 -0400
Message-ID: <1116959200.8954.5.camel@localhost.localdomain>
References: <200505232121.j4NLLaYa000837@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        jgarzik@pobox.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200505232121.j4NLLaYa000837@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>On Mon, 2005-05-23 at 14:21 -0700, Jay Vosburgh wrote:
David S. Miller <davem@davemloft.net> wrote:
>Patch doesn't apply, tabs turned into spaces by your
>email client.
>
>	As penance for test applying trivial patches by hand, here's a
>proper version.
>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

I guess I should be in the signed off list as the original author.
sorry I'm an idiot and copied and pasted my original message (to the
bonding-devel list) which screwed up the spacing.

Signed-off-by: Eric Paris <eparis@parisplace.org>
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
