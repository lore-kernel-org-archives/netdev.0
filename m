From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding using arp_ip_target may stay down with active path
Date: Mon, 16 May 2005 13:34:37 -0700
Message-ID: <200505162034.j4GKYbch022992@death.nxdomain.ibm.com>
References: <eparis@parisplace.org>
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Paris <eparis@parisplace.org>
In-Reply-To: Message from Eric Paris <eparis@parisplace.org>
   of "Mon, 16 May 2005 14:41:25 EDT." <1116268885.3738.19.camel@dhcp59-180.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Paris <eparis@parisplace.org> wrote:

>[...]  Bring back up the interface connected to
>eth1.  At this point we have a "valid" connection since eth1 can talk to
>one of the arp targets.  But we are only sending arp requests on eth0
>(verify with tcpdump)

	The trick is to have a situation with a partitioned network and
a failure such that the device still has link, but does not respond to
the ARP queries.  That's not an unreasonable failure if there's a switch
in each path to the arp_ip_target peers (which is how I set it up
locally).

>The patch below has been tested by me and appears to fix the problem.
>All of the failover tests I performed seem to work including pulling
>cables and stopping responses from the arp_ip_target entries.  

	The patch looks good to me, also (although I made the change by
hand instead of via patch).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


--- linux-2.6.11/drivers/net/bonding/bond_main.c.orig   2005-05-12 12:22:52.000000000 -0400
+++ linux-2.6.11/drivers/net/bonding/bond_main.c        2005-05-12 15:13:53.000000000 -0400
@@ -3046,7 +3046,7 @@ static void bond_activebackup_arp_mon(st
                        bond_set_slave_inactive_flags(bond->current_arp_slave);

                        /* search for next candidate */
-                       bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave) {
+                       bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
                                if (IS_UP(slave->dev)) {
                                        slave->link = BOND_LINK_BACK;
                                        bond_set_slave_active_flags(slave);
