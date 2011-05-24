From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: move is_vlan_dev into public header file (v2)
Date: Tue, 24 May 2011 15:03:34 -0400
Message-ID: <20110524190334.GE28521@hmsreliant.think-freely.org>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
 <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
 <1306261869-7276-2-git-send-email-nhorman@tuxdriver.com>
 <1306262195.2298.46.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46391 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab1EXTDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 15:03:38 -0400
Content-Disposition: inline
In-Reply-To: <1306262195.2298.46.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 11:36:35AM -0700, Joe Perches wrote:
> On Tue, 2011-05-24 at 14:31 -0400, Neil Horman wrote:
> > Migrate is_vlan_dev() to if_vlan.h so that core networkig can use it
> []
> > diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> []
> > @@ -110,6 +110,11 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
> >  	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
> >  }
> >  
> > +static inline int is_vlan_dev(struct net_device *dev)
> > +{
> > +        return dev->priv_flags & IFF_802_1Q_VLAN;
> > +}
> 
> perhaps:
> 
> static bool is_vlan_dev(const struct net_device *dev)
> {
> 	return !!(dev->priv_flags & IFF_802_1Q_VLAN);
> }
> 
I migrated this directly out of vlan.h as is.  I suppose we could change it, but
I'm not sure I see a need to do so immediately. All callers of this function
already work with it properly as defined currently (not that they wouldn't
otherwise).

Perhaps we could do a separate patch to fix this up as well as other common test
functions (br_port_exists, is_valid_iface, macvlan_port_exists,
netif_is_bond_slave, etc), all just return the result of a bitwise and
currently)

Neil

