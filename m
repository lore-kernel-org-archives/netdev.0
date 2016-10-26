From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] net: bonding: use new api ethtool_{get|set}_link_ksettings
Date: Wed, 26 Oct 2016 11:00:25 -0700
Message-ID: <11572.1477504825@famine>
References: <1477413691-10894-1-git-send-email-tremyfr@gmail.com>
Cc: vfalico@gmail.com, andy@greyhouse.net, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1477413691-10894-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe Reynes <tremyfr@gmail.com> wrote:

>The ethtool api {get|set}_settings is deprecated.
>We move this driver to new api {get|set}_link_ksettings.

	This is just an API change, i.e., no change to functionality?

	-J

>Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
>---
> drivers/net/bonding/bond_main.c |   16 ++++++++--------
> 1 files changed, 8 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index c9944d8..5708f17 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4080,16 +4080,16 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
> 	return ret;
> }
> 
>-static int bond_ethtool_get_settings(struct net_device *bond_dev,
>-				     struct ethtool_cmd *ecmd)
>+static int bond_ethtool_get_link_ksettings(struct net_device *bond_dev,
>+					   struct ethtool_link_ksettings *cmd)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
> 	unsigned long speed = 0;
> 	struct list_head *iter;
> 	struct slave *slave;
> 
>-	ecmd->duplex = DUPLEX_UNKNOWN;
>-	ecmd->port = PORT_OTHER;
>+	cmd->base.duplex = DUPLEX_UNKNOWN;
>+	cmd->base.port = PORT_OTHER;
> 
> 	/* Since bond_slave_can_tx returns false for all inactive or down slaves, we
> 	 * do not need to check mode.  Though link speed might not represent
>@@ -4100,12 +4100,12 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
> 		if (bond_slave_can_tx(slave)) {
> 			if (slave->speed != SPEED_UNKNOWN)
> 				speed += slave->speed;
>-			if (ecmd->duplex == DUPLEX_UNKNOWN &&
>+			if (cmd->base.duplex == DUPLEX_UNKNOWN &&
> 			    slave->duplex != DUPLEX_UNKNOWN)
>-				ecmd->duplex = slave->duplex;
>+				cmd->base.duplex = slave->duplex;
> 		}
> 	}
>-	ethtool_cmd_speed_set(ecmd, speed ? : SPEED_UNKNOWN);
>+	cmd->base.speed = speed ? : SPEED_UNKNOWN;
> 
> 	return 0;
> }
>@@ -4121,8 +4121,8 @@ static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
> 
> static const struct ethtool_ops bond_ethtool_ops = {
> 	.get_drvinfo		= bond_ethtool_get_drvinfo,
>-	.get_settings		= bond_ethtool_get_settings,
> 	.get_link		= ethtool_op_get_link,
>+	.get_link_ksettings	= bond_ethtool_get_link_ksettings,
> };
> 
> static const struct net_device_ops bond_netdev_ops = {
>-- 
>1.7.4.4

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
