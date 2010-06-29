From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] bonding: check if clients MAC addr has changed
Date: Tue, 29 Jun 2010 12:58:24 -0300
Message-ID: <20100629155824.GB13444@redhat.com>
References: <1277822481-25175-1-git-send-email-fleitner@redhat.com>
 <4C2A13A0.20200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	Andy Gospodarek <gospo@redhat.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab0F2P7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 11:59:16 -0400
Content-Disposition: inline
In-Reply-To: <4C2A13A0.20200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 11:39:12AM -0400, Brian Haley wrote:
> On 06/29/2010 10:41 AM, Flavio Leitner wrote:
> > diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> > index 40fdc41..67154bb 100644
> > --- a/drivers/net/bonding/bond_alb.c
> > +++ b/drivers/net/bonding/bond_alb.c
> > @@ -340,7 +340,8 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
> >  
> >  	if ((client_info->assigned) &&
> >  	    (client_info->ip_src == arp->ip_dst) &&
> > -	    (client_info->ip_dst == arp->ip_src)) {
> > +	    (client_info->ip_dst == arp->ip_src) &&
> > +	    (memcmp(client_info->mac_dst, arp->mac_src, ETH_ALEN))) {
> >  		/* update the clients MAC address */
> >  		memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
> >  		client_info->ntt = 1;
> 
> compare_ether_addr_64bits() ?

yeah, sounds better. Bonding driver is using it already in
many other places.

-- 
Flavio
