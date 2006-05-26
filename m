From: Pradeep Dalvi <pradeep@linsyssoft.com>
Subject: Re: [PATCH 1/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 14:14:32 +0000
Message-ID: <1148652872.3453.100.camel@arya.linsyssoft.com>
References: <Pine.LNX.4.33.0605250347050.5844-100000@unmsrvr>
	 <20060525093349.3f42220a@dxpl.pdx.osdl.net>
Reply-To: pradeep@linsyssoft.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:26216 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1750801AbWEZOa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:30:56 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525093349.3f42220a@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following are the minor changes for [PATCH 1/9] in accordance with the
given suggestions.

Regards,
pradeep

diff -u linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
--- linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
2006-05-25 02:43:22.000000000 -0700
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_ethtool.c
2006-05-26 04:05:34.000000000 -0700
@@ -145,7 +145,7 @@

                ecmd->port = PORT_TP;

-               if (port->state) {
+               if (dev->flags & IFF_UP) {
                        ecmd->speed = port->link_speed;
                        ecmd->duplex = port->link_duplex;
                } else
@@ -512,16 +512,6 @@
        ring->rx_jumbo_pending = 0;
 }

-/*
- * Note: This change will be reflected in all the four ports as there
is
- * only one common adapter.
- */
-static int
-netxen_nic_set_ringparam(struct net_device *dev, struct
ethtool_ringparam *ring)
-{
-       return 0;
-}
-
 static void
 netxen_nic_get_pauseparam(struct net_device *dev,
                          struct ethtool_pauseparam *pause)
@@ -781,7 +771,6 @@
        .get_eeprom_len = netxen_nic_get_eeprom_len,
        .get_eeprom = netxen_nic_get_eeprom,
        .get_ringparam = netxen_nic_get_ringparam,
-       .set_ringparam = netxen_nic_set_ringparam,
        .get_pauseparam = netxen_nic_get_pauseparam,
        .set_pauseparam = netxen_nic_set_pauseparam,
        .get_rx_csum = netxen_nic_get_rx_csum,


On Thu, 2006-05-25 at 09:33 -0700, Stephen Hemminger wrote:
> Minor nits.
> 
> On Thu, 25 May 2006 03:48:38 -0700 (PDT)
> "Linsys Contractor Amit S. Kale" <amitkale@unminc.com> wrote:
> 
> > +/*
> > + * Note: This change will be reflected in all the four ports as there is 
> > + * only one common adapter.
> > + */
> > +static int
> > +netxen_nic_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
> > +{
> > +	return 0;
> > +}
> 
> Why not just return have no hook if you can't set parameters.  Then the ioctl
> will return not supported -EOPNOTSUPP
> 
> >
> > +static u32 netxen_nic_get_rx_csum(struct net_device *dev)
> > +{
> > +	return (dev->features & NETIF_F_HW_CSUM);
> > +}
> 
> 
> You got receive and transmit checksum confused.  You need to separate
> checksumming on output (dev->features & NETIF_F_HW_CSUM) versus receive
> checksum (controlled by hardware and usually a flag in private data structure).
> 
> > +static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
> > +{
> > +	if (data)
> > +		dev->features |= NETIF_F_HW_CSUM;
> > +	else
> > +		dev->features &= (~NETIF_F_HW_CSUM);
> > +
> > +	if (netif_running(dev)) {
> > +		dev->stop(dev);	/* verify */
> > +		dev->open(dev);
> 
> What if open fail fails?  Then you have an "interesting" recovery
> situation.  
> > +	}
> > +	return 0;
> > +}
> > 
> 

-- 
pradeep

