From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3 net-next 1/2] liquidio: switchdev support for LiquidIO
 NIC
Date: Wed, 1 Nov 2017 14:02:07 +0100
Message-ID: <20171101130207.GH12680@lunn.ch>
References: <20171031230420.GA3615@felix-thinkpad.cavium.com>
 <20171031230453.GA3630@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:36481 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754618AbdKANCL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 09:02:11 -0400
Content-Disposition: inline
In-Reply-To: <20171031230453.GA3630@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int
> +lio_pf_switchdev_attr_get(struct net_device *dev, struct switchdev_attr *attr)
> +{
> +	struct lio *lio = GET_LIO(dev);
> +
> +	switch (attr->id) {
> +	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
> +		attr->u.ppid.id_len = ETH_ALEN;
> +		ether_addr_copy(attr->u.ppid.id,
> +				(void *)&lio->linfo.hw_addr + 2);

The + 2 seems odd. Please could you explain why it is there?


> +static int lio_vf_rep_open(struct net_device *ndev);
> +static int lio_vf_rep_stop(struct net_device *ndev);
> +static int lio_vf_rep_pkt_xmit(struct sk_buff *skb, struct net_device *ndev);
> +static void lio_vf_rep_tx_timeout(struct net_device *netdev);
> +static int lio_vf_rep_phys_port_name(struct net_device *dev,
> +				     char *buf, size_t len);
> +static void lio_vf_rep_get_stats64(struct net_device *dev,
> +				   struct rtnl_link_stats64 *stats64);
> +static int lio_vf_rep_change_mtu(struct net_device *ndev, int new_mtu);
> +
> +static const struct net_device_ops lio_vf_rep_ndev_ops = {
> +	.ndo_open = lio_vf_rep_open,
> +	.ndo_stop = lio_vf_rep_stop,
> +	.ndo_start_xmit = lio_vf_rep_pkt_xmit,
> +	.ndo_tx_timeout = lio_vf_rep_tx_timeout,
> +	.ndo_get_phys_port_name = lio_vf_rep_phys_port_name,
> +	.ndo_get_stats64 = lio_vf_rep_get_stats64,
> +	.ndo_change_mtu = lio_vf_rep_change_mtu,
> +};

Please don't use forward references. Change the order of the code and
put this structure towards the end of the file.

> +lio_vf_rep_phys_port_name(struct net_device *dev,
> +			  char *buf, size_t len)
> +{
> +	struct lio_vf_rep_desc *vf_rep = netdev_priv(dev);
> +	struct octeon_device *oct = vf_rep->oct;
> +	int ret;
> +
> +	ret = snprintf(buf, len, "pf%dvf%d", oct->pf_num,
> +		       vf_rep->ifidx - oct->pf_num * 64 - 1);
> +	if (ret >= len)
> +		return -EOPNOTSUPP;

EOPNOTSUPP seems an odd return code for too short a buffer?

	   Andrew
