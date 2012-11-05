From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v3 net-next] bonding: extend bond_arp_send_all to bridge devices
Date: Mon, 05 Nov 2012 14:45:45 -0800
Message-ID: <26061.1352155545@death.nxdomain>
References: <1352154649-21089-1-git-send-email-chris.j.arges@canonical.com>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1352154649-21089-1-git-send-email-chris.j.arges@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris J Arges <chris.j.arges@canonical.com> wrote:

>ARP monitoring does not work when we have a network in the
>following configuration:
>
>eth0----+ +----bond0.100----br0-100---{+virtual machines
>          | |
>          +----bond0----+----br0---(fixed IP)->--{LAN arp_ip_target}
>          | |
>eth1----+ +----bond0.200----br0-200---{+virtual machines
>
>This patch extends bond_arp_send_all to check if a device
>is also in a bridge.
>
>This is related to the following issues:
>http://launchpad.net/bugs/736226
>http://bugzilla.kernel.org/show_bug.cgi?id=31822
>
>Thanks to help from Andy Gospodarek <andy@greyhouse.net>.
>
>Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>

	What has changed that you're up to version 3 now?

> drivers/net/bonding/bond_main.c |   12 ++++++++++++
> 1 file changed, 12 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b2530b0..cb791f6 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2708,6 +2708,18 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 			continue;
> 		}
>
>+		/*
>+		 * Check if the target is part of a bridge.
>+		 */

		/* Comment should be formatted like this.
		 */

>+		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
>+			/* Confirm addr is part of the bridge */
>+			addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
>+
>+			/* Send ARP request */

	I think this comment is unnecessary.

	-J

>+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);
>+			continue;
>+		}
>+
> 		if (net_ratelimit()) {
> 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
> 				   bond->dev->name, &targets[i],
>-- 
>1.7.9.5
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
