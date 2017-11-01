From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH V3 net-next 1/2] liquidio: switchdev support for LiquidIO
 NIC
Date: Wed, 1 Nov 2017 12:29:48 -0700
Message-ID: <20171101192948.GA21476@felix-thinkpad.cavium.com>
References: <20171031230420.GA3615@felix-thinkpad.cavium.com>
 <20171031230453.GA3630@felix-thinkpad.cavium.com>
 <20171101130207.GH12680@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0043.outbound.protection.outlook.com ([104.47.36.43]:15589
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755138AbdKAT36 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 15:29:58 -0400
Content-Disposition: inline
In-Reply-To: <20171101130207.GH12680@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 02:02:07PM +0100, Andrew Lunn wrote:
> > +static int
> > +lio_pf_switchdev_attr_get(struct net_device *dev, struct switchdev_attr *attr)
> > +{
> > +	struct lio *lio = GET_LIO(dev);
> > +
> > +	switch (attr->id) {
> > +	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
> > +		attr->u.ppid.id_len = ETH_ALEN;
> > +		ether_addr_copy(attr->u.ppid.id,
> > +				(void *)&lio->linfo.hw_addr + 2);
> 
> The + 2 seems odd. Please could you explain why it is there?

The "+ 2" is the byte offset of the start of the mac address.  In a
future patch, we will replace "(void *)&lio->linfo.hw_addr + 2" with
"dev->dev_addr" which is an elegant equivalent.


> > +static int lio_vf_rep_open(struct net_device *ndev);
> > +static int lio_vf_rep_stop(struct net_device *ndev);
> > +static int lio_vf_rep_pkt_xmit(struct sk_buff *skb, struct net_device *ndev);
> > +static void lio_vf_rep_tx_timeout(struct net_device *netdev);
> > +static int lio_vf_rep_phys_port_name(struct net_device *dev,
> > +				     char *buf, size_t len);
> > +static void lio_vf_rep_get_stats64(struct net_device *dev,
> > +				   struct rtnl_link_stats64 *stats64);
> > +static int lio_vf_rep_change_mtu(struct net_device *ndev, int new_mtu);
> > +
> > +static const struct net_device_ops lio_vf_rep_ndev_ops = {
> > +	.ndo_open = lio_vf_rep_open,
> > +	.ndo_stop = lio_vf_rep_stop,
> > +	.ndo_start_xmit = lio_vf_rep_pkt_xmit,
> > +	.ndo_tx_timeout = lio_vf_rep_tx_timeout,
> > +	.ndo_get_phys_port_name = lio_vf_rep_phys_port_name,
> > +	.ndo_get_stats64 = lio_vf_rep_get_stats64,
> > +	.ndo_change_mtu = lio_vf_rep_change_mtu,
> > +};
> 
> Please don't use forward references. Change the order of the code and
> put this structure towards the end of the file.

We will fix this in a future patch.


> > +lio_vf_rep_phys_port_name(struct net_device *dev,
> > +			  char *buf, size_t len)
> > +{
> > +	struct lio_vf_rep_desc *vf_rep = netdev_priv(dev);
> > +	struct octeon_device *oct = vf_rep->oct;
> > +	int ret;
> > +
> > +	ret = snprintf(buf, len, "pf%dvf%d", oct->pf_num,
> > +		       vf_rep->ifidx - oct->pf_num * 64 - 1);
> > +	if (ret >= len)
> > +		return -EOPNOTSUPP;
> 
> EOPNOTSUPP seems an odd return code for too short a buffer?

We will replace that with ENOBUFS in a future patch.
