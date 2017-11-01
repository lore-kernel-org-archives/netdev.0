From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH V3 net-next 1/2] liquidio: switchdev support for
 LiquidIO NIC
Date: Wed, 1 Nov 2017 13:14:06 -0700
Message-ID: <20171101131406.2c1e61ed@cakuba.netronome.com>
References: <20171031230420.GA3615@felix-thinkpad.cavium.com>
        <20171031230453.GA3630@felix-thinkpad.cavium.com>
        <20171101130207.GH12680@lunn.ch>
        <20171101192948.GA21476@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com,
        Or Gerlitz <gerlitz.or@gmail.com>, michael.chan@broadcom.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: Felix Manlunas <felix.manlunas@cavium.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:60481 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755008AbdKAUOP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 16:14:15 -0400
In-Reply-To: <20171101192948.GA21476@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Nov 2017 12:29:48 -0700, Felix Manlunas wrote:
> > > +lio_vf_rep_phys_port_name(struct net_device *dev,
> > > +			  char *buf, size_t len)
> > > +{
> > > +	struct lio_vf_rep_desc *vf_rep = netdev_priv(dev);
> > > +	struct octeon_device *oct = vf_rep->oct;
> > > +	int ret;
> > > +
> > > +	ret = snprintf(buf, len, "pf%dvf%d", oct->pf_num,
> > > +		       vf_rep->ifidx - oct->pf_num * 64 - 1);
> > > +	if (ret >= len)
> > > +		return -EOPNOTSUPP;  
> > 
> > EOPNOTSUPP seems an odd return code for too short a buffer?  
> 
> We will replace that with ENOBUFS in a future patch.

Strangely enough mlx5 and bnxt also use EOPNOTSUPP if string doesn't
fit.  Others use EINVAL, IMHO that's more appropriate.
