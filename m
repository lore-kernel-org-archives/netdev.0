From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Wed, 11 Jan 2017 08:29:19 +0100
Message-ID: <20170111072919.GC1852@nanopsycho>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
 <20170110203237.23907-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35469 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932601AbdAKH3W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 02:29:22 -0500
Received: by mail-wm0-f67.google.com with SMTP id l2so35065824wml.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 23:29:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170110203237.23907-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 10, 2017 at 09:32:36PM CET, f.fainelli@gmail.com wrote:
>Return the physical port number of a DSA created network device using
>ndo_get_phys_port_name().
>
>Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>


>---
> net/dsa/slave.c | 10 ++++++++++
> 1 file changed, 10 insertions(+)
>
>diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>index 5cd5b8137c08..fed3fbd403cb 100644
>--- a/net/dsa/slave.c
>+++ b/net/dsa/slave.c
>@@ -990,6 +990,15 @@ static int dsa_slave_get_phys_port_id(struct net_device *dev,
> 
> 	ppid->id_len = sizeof(p->port);
> 	memcpy(ppid->id, &p->port, ppid->id_len);
>+}
>+
>+static int dsa_slave_get_phys_port_name(struct net_device *dev,
>+					char *name, size_t len)
>+{
>+	struct dsa_slave_priv *p = netdev_priv(dev);
>+
>+	if (snprintf(name, len, "p%d", p->port) >= len)
>+		return -EINVAL;
> 
> 	return 0;
> }
>@@ -1042,6 +1051,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
> 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
> 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
> 	.ndo_get_phys_port_id	= dsa_slave_get_phys_port_id,
>+	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
> };
> 
> static const struct switchdev_ops dsa_slave_switchdev_ops = {
>-- 
>2.9.3
>
