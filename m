From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next] bonding: ratelimit pr_warn()s in 802.3ad mode
Date: Wed, 19 Mar 2014 10:23:00 +0100
Message-ID: <20140319092300.GA17378@redhat.com>
References: <1394988903-19099-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758262AbaCSJXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 05:23:08 -0400
Content-Disposition: inline
In-Reply-To: <1394988903-19099-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 16, 2014 at 05:55:03PM +0100, Veaceslav Falico wrote:
>Only ratelimit the ones that might spam, omiting the ones from
>enslave/deslave.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

(sorry for the noise)

David, I've seen that this patch was applied to the tree - but either my
mail broke, or did you stop sending notifications on accepted patches?

Thanks a lot, and sorry again for bugging.

>---
> drivers/net/bonding/bond_3ad.c | 34 +++++++++++++++++-----------------
> 1 file changed, 17 insertions(+), 17 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index dee2a84..b667a51 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -1284,11 +1284,11 @@ static void ad_port_selection_logic(struct port *port)
> 			/* meaning: the port was related to an aggregator
> 			 * but was not on the aggregator port list
> 			 */
>-			pr_warn("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
>-				port->slave->bond->dev->name,
>-				port->actor_port_number,
>-				port->slave->dev->name,
>-				port->aggregator->aggregator_identifier);
>+			pr_warn_ratelimited("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
>+					    port->slave->bond->dev->name,
>+					    port->actor_port_number,
>+					    port->slave->dev->name,
>+					    port->aggregator->aggregator_identifier);
> 		}
> 	}
> 	/* search on all aggregators for a suitable aggregator for this port */
>@@ -1445,9 +1445,9 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
> 		break;
>
> 	default:
>-		pr_warn("%s: Impossible agg select mode %d\n",
>-			curr->slave->bond->dev->name,
>-			__get_agg_selection_mode(curr->lag_ports));
>+		pr_warn_ratelimited("%s: Impossible agg select mode %d\n",
>+				    curr->slave->bond->dev->name,
>+				    __get_agg_selection_mode(curr->lag_ports));
> 		break;
> 	}
>
>@@ -1560,9 +1560,9 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>
> 		/* check if any partner replys */
> 		if (best->is_individual) {
>-			pr_warn("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
>-				best->slave ?
>-				best->slave->bond->dev->name : "NULL");
>+			pr_warn_ratelimited("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
>+					    best->slave ?
>+					    best->slave->bond->dev->name : "NULL");
> 		}
>
> 		best->is_active = 1;
>@@ -2081,8 +2081,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 		/* select the active aggregator for the bond */
> 		if (port) {
> 			if (!port->slave) {
>-				pr_warn("%s: Warning: bond's first port is uninitialized\n",
>-					bond->dev->name);
>+				pr_warn_ratelimited("%s: Warning: bond's first port is uninitialized\n",
>+						    bond->dev->name);
> 				goto re_arm;
> 			}
>
>@@ -2096,8 +2096,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> 	bond_for_each_slave_rcu(bond, slave, iter) {
> 		port = &(SLAVE_AD_INFO(slave).port);
> 		if (!port->slave) {
>-			pr_warn("%s: Warning: Found an uninitialized port\n",
>-				bond->dev->name);
>+			pr_warn_ratelimited("%s: Warning: Found an uninitialized port\n",
>+					    bond->dev->name);
> 			goto re_arm;
> 		}
>
>@@ -2158,8 +2158,8 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
> 		port = &(SLAVE_AD_INFO(slave).port);
>
> 		if (!port->slave) {
>-			pr_warn("%s: Warning: port of slave %s is uninitialized\n",
>-				slave->dev->name, slave->bond->dev->name);
>+			pr_warn_ratelimited("%s: Warning: port of slave %s is uninitialized\n",
>+					    slave->dev->name, slave->bond->dev->name);
> 			return ret;
> 		}
>
>-- 
>1.8.4
>
