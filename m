From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] Revert "net: dsa: Implement
 ndo_get_phys_port_id"
Date: Wed, 11 Jan 2017 08:29:39 +0100
Message-ID: <20170111072939.GD1852@nanopsycho>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
 <20170110203237.23907-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33300 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdAKH3m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 02:29:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id r144so26156967wme.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 23:29:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170110203237.23907-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 10, 2017 at 09:32:37PM CET, f.fainelli@gmail.com wrote:
>This reverts commit 3a543ef479868e36c95935de320608a7e41466ca ("net: dsa:
>Implement ndo_get_phys_port_id") since it misuses the purpose of
>ndo_get_phys_port_id(). We have ndo_get_phys_port_name() to do the
>correct thing for us now.
>
>Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>


>---
> net/dsa/slave.c | 10 ----------
> 1 file changed, 10 deletions(-)
>
>diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>index fed3fbd403cb..0cdcaf526987 100644
>--- a/net/dsa/slave.c
>+++ b/net/dsa/slave.c
>@@ -983,15 +983,6 @@ static void dsa_slave_poll_controller(struct net_device *dev)
> }
> #endif
> 
>-static int dsa_slave_get_phys_port_id(struct net_device *dev,
>-				      struct netdev_phys_item_id *ppid)
>-{
>-	struct dsa_slave_priv *p = netdev_priv(dev);
>-
>-	ppid->id_len = sizeof(p->port);
>-	memcpy(ppid->id, &p->port, ppid->id_len);
>-}
>-
> static int dsa_slave_get_phys_port_name(struct net_device *dev,
> 					char *name, size_t len)
> {
>@@ -1050,7 +1041,6 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
> 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
> 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
> 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
>-	.ndo_get_phys_port_id	= dsa_slave_get_phys_port_id,
> 	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
> };
> 
>-- 
>2.9.3
>
