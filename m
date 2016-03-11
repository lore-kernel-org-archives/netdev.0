From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] ldmvsw: Add ldmvsw.c driver code
Date: Fri, 11 Mar 2016 14:30:22 -0500 (EST)
Message-ID: <20160311.143022.2226126311284772576.davem@davemloft.net>
References: <cover.1457401532.git.Aaron.Young@oracle.com>
	<cover.1457401532.git.Aaron.Young@oracle.com>
	<f3e221f516c1514b7d60b8e8970130b4a31d1d59.1457401532.git.Aaron.Young@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com
To: Aaron.Young@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbcCKTaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:30:25 -0500
In-Reply-To: <f3e221f516c1514b7d60b8e8970130b4a31d1d59.1457401532.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <Aaron.Young@oracle.com>
Date: Tue,  8 Mar 2016 07:02:35 -0800

> +static struct vnet *vsw_get_vnet(struct mdesc_handle *hp,
> +				 u64 port_node,
> +				 u64 *handle)
> +{
> +	struct vnet *vp;
> +	struct vnet *iter;
> +	const u64 *local_mac = NULL;
> +	const u64 *cfghandle = NULL;
> +	u64 a;

Please order local variable declarations from longest to shortest line (reverse
christmas tree).

> +static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
> +{
> +	struct mdesc_handle *hp;
> +	struct vnet_port *port;
> +	unsigned long flags;
> +	struct vnet *vp;
> +	struct net_device *dev;
> +	const u64 *rmac;
> +	int len, i, err;
> +	const u64 *port_id;
> +	u64 handle;

Likewise.

> +	err = register_netdev(dev);
> +	if (err) {
> +		pr_err("Cannot register net device, aborting\n");
> +		goto err_out_free_ldc;
> +	}
> +
> +	netif_napi_add(dev, &port->napi, vnet_poll_common,
> +		       NAPI_POLL_WEIGHT);
> +
> +	INIT_LIST_HEAD(&port->list);

You cannot register the netdevice so early.  It must be registerred only after
every single piece of software state is initialized and setup.

At the very precise moment you invoke register_netdev() the device can
be brought up and attempted to be used.
