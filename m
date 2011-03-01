From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT/PATCH v3] xen network backend driver
Date: Tue, 01 Mar 2011 12:28:46 +0000
Message-ID: <1298982526.3437.5.camel@localhost>
References: <1298914061.5034.996.camel@zakaz.uk.xensource.com>
	 <1298919198.2569.14.camel@bwh-desktop>
	 <1298974009.5034.2029.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43353 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab1CAM2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:28:53 -0500
In-Reply-To: <1298974009.5034.2029.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-01 at 10:06 +0000, Ian Campbell wrote:
> On Mon, 2011-02-28 at 18:53 +0000, Ben Hutchings wrote:
> > On Mon, 2011-02-28 at 17:27 +0000, Ian Campbell wrote:
> 
> > This should be defined as unsigned long (ideally it would be u64, but
> > that can't be updated atomically on 32-bit systems).
> [...]
> > Don't update last_rx; it's only needed on slave devices of a bond, and
> > the bonding driver takes care of it now.
> 
> I made these two changes.
> 
> > [...]
> > > +static int xenvif_change_mtu(struct net_device *dev, int mtu)
> > > +{
> > > +	struct xenvif *vif = netdev_priv(dev);
> > > +	int max = vif->can_sg ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> > > +	if (mtu > max)
> > > +		return -EINVAL;
> > > +	dev->mtu = mtu;
> > > +	return 0;
> > > +}
> > [...]
> > 
> > Since any VLAN tag must be inserted inline, shouldn't the MTU limit be
> > 65535 - VLAN_ETH_HLEN?
> 
> In that case shouldn't the other case also be ETH_FRAME_LEN -
> VLAN_ETH_HLEN?
[...]

IEEE 802.3, in its infinite wisdom, says that the maximum frame length
is 1514, except that when an 802.1q tag is present it is 1518.  So the
MTU for standard Ethernet remains 1500, regardless of the use of VLANs.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

