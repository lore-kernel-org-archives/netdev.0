From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [v4 Patch 1/2] s2io: add dynamic LRO disable support
Date: Tue, 22 Jun 2010 14:31:02 +0200
Message-ID: <20100622143102.68a59849@dhcp-lab-109.englab.brq.redhat.com>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
	<1277207080.2091.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, herbert.xu@redhat.com,
	Ramkrishna.Vepa@exar.com, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755884Ab0FVMbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 08:31:14 -0400
In-Reply-To: <1277207080.2091.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jun 2010 12:44:40 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2010-06-22 at 04:50 -0400, Amerigo Wang wrote:
> > This patch adds dynamic LRO diable support for s2io net driver.
> > 
> > (I don't have s2io card, so only did compiling test. Anyone who wants
> > to test this is more than welcome.)
> > 
> > This is based on Neil's initial work, and heavily modified
> > based on Ramkrishna's suggestions.
> [...]
> > +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
> > +{
> > +	struct s2io_nic *sp = netdev_priv(dev);
> > +	int rc = 0;
> > +	int changed = 0;
> > +
> > +	if (data & ~ETH_FLAG_LRO)
> > +		return -EOPNOTSUPP;
> > +
> > +	if (data & ETH_FLAG_LRO) {
> > +		if (lro_enable) {
> > +			if (!(dev->features & NETIF_F_LRO)) {
> > +				dev->features |= NETIF_F_LRO;
> > +				changed = 1;
> > +			}
> > +		} else
> > +			rc = -EOPNOTSUPP;
> 
> Should lro_enable=0 really prevent enabling it later?  This seems
> unusual.

We are doing this in bnx2x. Current Amerigo patch change to the
same behavior mlx4. For me that have sense - if you want to disallow
LRO - use module option.

In this case however lro_enable variable looks obsolete from times
where there was no ethtool possibility to dynamic set/unset LRO.
Perhaps it should be removed at all, but maybe not as part
of that patch.

Stanislaw
